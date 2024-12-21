import 'package:bali_heritage/widgets/left_drawer.dart';
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
  Future<List<Bookmark>> fetchBookmarks(CookieRequest request) async {
    final response = await request.get('http://localhost:8000/bookmarks/json/');
    List<Bookmark> listBookmark = [];
    for (var d in response) {
      if (d != null) {
        listBookmark.add(Bookmark.fromJson(d));
      }
    }
    return listBookmark;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.read<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmark Product List'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: FutureBuilder(
        future: fetchBookmarks(request),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada bookmark produk.',
                style: TextStyle(fontSize: 20, color: Color(0xff59A5D8)),
              ),
            );
          } else {
            final bookmarks = snapshot.data!;
            return ListView.builder(
              itemCount: bookmarks.length,
              itemBuilder: (_, index) {
                final bookmark = bookmarks[index];
                return BookmarkCard(
                  bookmark: bookmark,
                  onDelete: () {
                    setState(() {
                      bookmarks.removeAt(index); // Menghapus item dari UI
                    });
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
