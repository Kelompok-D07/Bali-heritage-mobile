import 'package:bali_heritage/widgets/left_drawer.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:bali_heritage/Bookmarks/models/bookmark_models.dart'; // Import model Bookmark
import 'package:bali_heritage/Bookmarks/widgets/bookmark_card.dart'; // Import widget BookmarkCard
import 'package:http/http.dart' as http;

import 'package:bali_heritage/Homepage/models/Category.dart'; // Import kategori

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({super.key});

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  late Future<List<Bookmark>> _bookmarks;
  late Future<List<Category>> _categories;
  String selectedCategory = 'ALL';

  @override
  void initState() {
    super.initState();
  }

  Future<List<Bookmark>> fetchBookmarks(CookieRequest request, String category) async {
    final response = await request.get(
      'https://muhammad-adiansyah-baliheritage.pbp.cs.ui.ac.id/bookmarks/json/?category=$category',
    );
    List<Bookmark> listBookmark = [];
    for (var d in response) {
      if (d != null) {
        listBookmark.add(Bookmark.fromJson(d));
      }
    }
    return listBookmark;
  }

  Future<List<Category>> fetchCategories() async {
    final response = await http.get(Uri.parse('https://muhammad-adiansyah-baliheritage.pbp.cs.ui.ac.id/get-categories/'));
    if (response.statusCode == 200) {
      final List<Category> categories = categoryFromJson(response.body);
      return categories;
    } else {
      throw Exception('Failed to load categories');
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.read<CookieRequest>();

    _bookmarks = fetchBookmarks(request, selectedCategory);
    _categories = fetchCategories();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmark Product List'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Column(
        children: [
          FutureBuilder<List<Category>>(
            future: _categories,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                final categories = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Pilih Kategori',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedCategory,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCategory = newValue!;
                        _bookmarks = fetchBookmarks(request, selectedCategory);
                      });
                    },
                    items: [
                      const DropdownMenuItem(
                        value: 'ALL',
                        child: Text('All Categories'),
                      ),
                      ...categories.map<DropdownMenuItem<String>>((category) {
                        return DropdownMenuItem<String>(
                          value: category.pk.toString(),
                          child: Text(category.fields.name),
                        );
                      }).toList(),
                    ],
                  ),
                );
              } else {
                return const Center(child: Text('No categories available.'));
              }
            },
          ),
          Expanded(
            child: FutureBuilder<List<Bookmark>>(
              future: _bookmarks,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada bookmark produk',
                      style: TextStyle(fontSize: 20, color: Color.fromARGB(255, 229, 152, 84)),
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
                            bookmarks.removeAt(index);
                          });
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
