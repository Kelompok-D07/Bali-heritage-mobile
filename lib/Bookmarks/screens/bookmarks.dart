import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:bali_heritage/Bookmarks/models/bookmark_models.dart'; // Pastikan sudah import model Bookmark

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({super.key});

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  Future<List<Bookmark>> fetchBookmarks(CookieRequest request) async {
    // Ganti URL sesuai dengan endpoint yang tepat di backend
    final response = await request.get('http://127.0.0.1:8000/bookmarks/json/');
    
    // Melakukan decode response menjadi bentuk json
    var data = response;
    
    // Melakukan konversi data json menjadi object Bookmark
    List<Bookmark> listBookmarks = [];
    for (var d in data) {
      if (d != null) {
        listBookmarks.add(Bookmark.fromJson(d));
      }
    }
    return listBookmarks;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmark Product List'),
      ),
      body: FutureBuilder(
        future: fetchBookmarks(request),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (!snapshot.hasData) {
              return const Column(
                children: [
                  Text(
                    'Belum ada bookmark produk.',
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
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Product ID: ${snapshot.data![index].fields.product}',
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Notes: ${snapshot.data![index].fields.notes}',
                        style: const TextStyle(fontSize: 16.0),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Created At: ${snapshot.data![index].fields.createdAt.toLocal().toString()}',
                        style: const TextStyle(fontSize: 14.0),
                      ),
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
