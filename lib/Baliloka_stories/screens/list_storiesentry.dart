import 'package:flutter/material.dart';
import 'package:bali_heritage/Baliloka_stories/models/stories_entry.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
// import 'package:[APP_NAME]/widgets/left_drawer.dart';

class StoriesEntryPage extends StatefulWidget {
  const StoriesEntryPage({super.key});

  @override
  State<StoriesEntryPage> createState() => _StoriesEntryPageState();
}

class _StoriesEntryPageState extends State<StoriesEntryPage> {
  Future<List<StoriesEntry>> fetchStories(CookieRequest request) async {
    final response = await request.get('http://127.0.0.1:8000/json/');
    
    // Melakukan decode response menjadi bentuk json
    var data = response;
    
    // Melakukan konversi data json menjadi object MoodEntry
    List<StoriesEntry> listStories = [];
    for (var d in data) {
      if (d != null) {
        listStories.add(StoriesEntry.fromJson(d));
      }
    }
    return listStories;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stories Entry List'),
      ),
      // drawer: const LeftDrawer(),
      body: FutureBuilder(
        future: fetchStories(request),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (!snapshot.hasData) {
              return const Column(
                children: [
                  Text(
                    'Belum ada data Stories.',
                    style: TextStyle(fontSize: 20, color: Color(0xff59A5D8)),
                  ),
                  SizedBox(height: 8),
                ],
              );
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (_, index) => Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${snapshot.data![index].fields.name}",
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text("${snapshot.data![index].fields.name}"),
                      const SizedBox(height: 10),
                      Text("${snapshot.data![index].fields.image}"),
                      const SizedBox(height: 10),
                      Text("${snapshot.data![index].fields.description}")
                    ],
                  ),
                ),
              );
            }
          }
        },
      ),
    );
  }
}