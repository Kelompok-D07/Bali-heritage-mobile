import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:bali_heritage/Bookmarks/models/bookmark_models.dart'; // Import model Bookmark
import 'package:bali_heritage/Bookmarks/widgets/bookmark_card.dart'; // Import widget BookmarkCard

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({super.key});

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  List<Bookmark> dummyBookmarks = [
    Bookmark(
      model: 'bookmark',
      pk: 1,
      fields: Fields(
        user: 101,
        product: 1001,
        notes: 'This is a great product for wellness.',
        createdAt: DateTime.now().subtract(Duration(days: 2)),
      ),
    ),
    Bookmark(
      model: 'bookmark',
      pk: 2,
      fields: Fields(
        user: 102,
        product: 1002,
        notes: 'Highly recommended for relaxation.',
        createdAt: DateTime.now().subtract(Duration(days: 5)),
      ),
    ),
    Bookmark(
      model: 'bookmark',
      pk: 3,
      fields: Fields(
        user: 103,
        product: 1003,
        notes: 'Love the soothing aroma! gokil',
        createdAt: DateTime.now().subtract(Duration(days: 10)),
      ),
    ),
  ];

  // Fungsi untuk mengambil data dummy
  Future<List<Bookmark>> fetchBookmarks() async {
    await Future.delayed(const Duration(seconds: 2)); // Simulasi delay
    return dummyBookmarks; // Mengembalikan data dummy
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmark Product List'),
      ),
      body: FutureBuilder(
        future: fetchBookmarks(),
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
                itemBuilder: (_, index) {
                  final bookmark = snapshot.data![index];
                  return BookmarkCard(bookmark: bookmark); // Menggunakan BookmarkCard untuk setiap item
                },
              );
            }
          }
        },
      ),
    );
  }
}
