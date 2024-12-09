import 'package:flutter/material.dart';

// Import model yang dibutuhkan
import 'package:bali_heritage/Bookmarks/models/bookmark_models.dart';

class BookmarkCard extends StatelessWidget {
  final Bookmark bookmark;

  const BookmarkCard({super.key, required this.bookmark});

  @override
  Widget build(BuildContext context) {
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
                'https://i.ibb.co/Kr4b0zJ/152013403-10158311889099633-8423107287930246533-o.jpg', // Masih pake dummy data
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
                      'Nama Produk', // Ganti dengan nama produk yang sebenarnya
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Deskripsi Produk
                    Text(
                      bookmark.fields.notes, // Menampilkan catatan atau deskripsi produk
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
                        bookmark.fields.notes.isNotEmpty
                            ? bookmark.fields.notes
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
                            // Fungsi untuk edit notes
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Edit Notes'),
                                  content: TextField(
                                    controller: TextEditingController(
                                      text: bookmark.fields.notes,
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: "Enter your notes",
                                    ),
                                    onChanged: (value) {
                                      // Handle note change
                                    },
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        // Simpan dan close dialog
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
