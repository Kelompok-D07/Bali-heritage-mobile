import 'dart:convert';

import 'package:bali_heritage/Homepage/screens/restaurant_page.dart';
import 'package:flutter/material.dart';

// Import model yang dibutuhkan
import 'package:bali_heritage/Bookmarks/models/bookmark_models.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class BookmarkCard extends StatefulWidget {
  final Bookmark bookmark;
  final VoidCallback onDelete;

  const BookmarkCard({super.key, required this.bookmark, required this.onDelete});

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
      child: InkWell(
        onTap: () {
          // Navigasi ke halaman detail restaurant
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RestaurantPage(
                restaurantName: widget.bookmark.fields.restaurantName,
              ),
            ),
          );
        },
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
                              : 'Belum ada notes',
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Tombol Edit Notes dan Delete
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
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
                                              'item_name': widget.bookmark.fields.product,
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
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () async {
                              // Tampilkan dialog konfirmasi sebelum menghapus
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Hapus Item'),
                                    content: const Text('Apakah Anda yakin ingin menghapus item ini dari bookmarks?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          // Tutup dialog tanpa melakukan apa pun
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Batal'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          // Kirim permintaan untuk menghapus item
                                          final response = await request.postJson(
                                            "http://localhost:8000/bookmarks/delete-bookmarks-flutter/${widget.bookmark.fields.product}/",
                                            jsonEncode(<String, String>{}),
                                          );

                                          if (response['status'] == 'success') {
                                            // Tampilkan notifikasi sukses
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: const Text('Item berhasil dihapus dari bookmarks!'),
                                                duration: const Duration(seconds: 2),
                                              ),
                                            );
                                            // Panggil callback untuk menghapus item dari UI
                                            widget.onDelete();
                                            Navigator.pop(context);
                                          } else {
                                            // Tampilkan notifikasi error
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Gagal menghapus item: ${response['message']}'),
                                                duration: const Duration(seconds: 2),
                                              ),
                                            );
                                          }
                                        },
                                        child: const Text('Hapus'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red, // Warna tombol untuk delete
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Delete'),
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
      ),
    );
  }
}