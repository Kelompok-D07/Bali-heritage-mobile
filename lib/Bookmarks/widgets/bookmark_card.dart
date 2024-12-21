import 'dart:convert';

import 'package:flutter/material.dart';

// Import model yang dibutuhkan
import 'package:bali_heritage/Bookmarks/models/bookmark_models.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class BookmarkCard extends StatefulWidget {
  final Bookmark bookmark;

  const BookmarkCard({super.key, required this.bookmark});

  @override
  _BookmarkCardState createState() => _BookmarkCardState();
}

class _BookmarkCardState extends State<BookmarkCard> {
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.bookmark.fields.notes);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _updateNotes(String newNotes) {
    setState(() {
      widget.bookmark.fields.notes = newNotes;
    });
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Card(
        elevation: 8, // Menggunakan shadow yang lebih tebal
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Border radius lebih besar
        ),
        color: Colors.white, // Background card
        child: Row(
          children: [
            // Gambar Produk dengan border-radius
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.bookmark.fields.image, // Masih pake dummy data
                width: 120,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12), // Menambah jarak antara gambar dan konten
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama Produk
                    Text(
                      widget.bookmark.fields.product, // Nama produk STRING
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Deskripsi Produk
                    Text(
                      widget.bookmark.fields.description, // Menampilkan deskripsi produk
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Display Notes
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange[200]!),
                      ),
                      child: Text(
                        widget.bookmark.fields.notes.isNotEmpty
                            ? widget.bookmark.fields.notes
                            : 'No notes yet.',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Tombol Edit Notes dan View Restaurant dalam satu Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Button View Restaurant
                        ElevatedButton(
                          onPressed: () {
                            // Aksi tombol View Restaurant
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[500],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('View Restaurant'),
                        ),
                        const SizedBox(width: 12), // Jarak kecil antara tombol
                        // Tombol Edit Notes
                        ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Edit Notes'),
                                  content: TextField(
                                    controller: _notesController,
                                    decoration: const InputDecoration(
                                      hintText: "Enter your notes",
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () async {
                                        // Simpan dan close dialog
                                        _updateNotes(_notesController.text);
                                        final response = await request.postJson(
                                            "http://localhost:8000/bookmarks/edit-notes/",
                                            jsonEncode(<String, String>{
                                                'item_id': widget.bookmark.fields.productId.toString(),
                                                'new_notes': _notesController.text,
                                            }),
                                        );

                                        if (response['status'] == 'success') {
                                          // Tampilkan SnackBar untuk notifikasi sukses
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: const Text('Notes berhasil diupdate!'),
                                              duration: const Duration(seconds: 2),
                                            ),
                                          );
                                        } else {
                                          // Tampilkan SnackBar untuk notifikasi error
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Gagal mengupdate notes: ${response['message']}'),
                                              duration: const Duration(seconds: 2),
                                            ),
                                          );
                                        }

                                        Navigator.pop(context);
                                        
                                      },
                                      child: const Text('Save'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple, // Warna tombol
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Edit Notes'),
                        ),
                      ],
                    ),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
