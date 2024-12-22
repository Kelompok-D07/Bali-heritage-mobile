import 'package:flutter/material.dart';
import 'package:bali_heritage/Baliloka_stories/models/stories_entry.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'storiesentry_form.dart';
import 'edit_stories_page.dart';

class StoriesEntryPage extends StatefulWidget {
  const StoriesEntryPage({super.key});

  @override
  State<StoriesEntryPage> createState() => _StoriesEntryPageState();
}

class _StoriesEntryPageState extends State<StoriesEntryPage> {
  Future<List<StoriesEntry>> fetchStories(CookieRequest request) async {
    final response = await request.get('https://muhammad-adiansyah-baliheritage.pbp.cs.ui.ac.id/stories/json/');

    if (response is List) {
      return response.map((json) => StoriesEntry.fromJson(json)).toList();
    } else {
      throw Exception("Invalid response format");
    }
  }

  void _showPopup(BuildContext context, StoriesEntry story) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.75,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.edit, color: Colors.blue),
                      title: const Text(
                        'Edit',
                        style: TextStyle(color: Colors.blue),
                      ),
                      onTap: () async {
                        Navigator.pop(context);
                        final updatedData = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditStoriesPage(story: story),
                          ),
                        );

                        if (updatedData != null && mounted) {
                          setState(() {
                            story.name = updatedData['name'];
                            story.description = updatedData['description'];
                            story.image = 'data:image/png;base64,' + updatedData['image'];
                          });
                        }
                      },
                    ),
                    const Divider(color: Colors.blue),
                    ListTile(
                      leading: const Icon(Icons.delete, color: Colors.red),
                      title: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                      onTap: () async {
                        Navigator.pop(context);
                        final request = context.read<CookieRequest>();
                        await handleDelete(request, story);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> handleDelete(CookieRequest request, StoriesEntry story) async {
    try {
      final response = await request.post(
        'https://muhammad-adiansyah-baliheritage.pbp.cs.ui.ac.id/stories/delete-flutter/${story.id}/',
        {},
      );

      if (response['status'] == 'success') {
        setState(() {
          // Menghapus cerita dari daftar
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Story deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete story'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor, 
        title: const Text(
          'Bali Stories',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.orange],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          FutureBuilder(
            future: fetchStories(request),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (!snapshot.hasData || snapshot.data.isEmpty) {
                return const Center(
                  child: Text(
                    'Belum ada data Stories.',
                    style: TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.6, // Memperpanjang card secara vertikal
                    ),
                    itemCount: snapshot.data.length,
                    itemBuilder: (_, index) {
                      final story = snapshot.data[index];
                      return Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  Center(
                                    child: Text(
                                      story.name,
                                      style: const TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  AspectRatio(
                                    aspectRatio: 1,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        story.image,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // Memberikan lebih banyak ruang untuk deskripsi
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Text(
                                        story.description,
                                        style: const TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.black, // Menjadikan tulisan deskripsi hitam
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                icon: const Icon(Icons.more_vert, color: Colors.black),
                                onPressed: () => _showPopup(context, story),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor.withOpacity(1), // Membuat warna lebih terang dengan opacity
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const StoriesEntryForm(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text(
          "Tambah Stories",
          style: TextStyle(fontWeight: FontWeight.bold), // Menebalkan teks
        ),
      ),
    );
  }
}
