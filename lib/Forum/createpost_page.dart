import 'package:flutter/material.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  // Nanti untuk rekomendasi restoran, kita bisa gunakan dropdown atau multi-select.
  // Untuk sementara, kita abaikan fitur ini atau sediakan placeholder.
  // Contoh: List<String> restaurants = []; // nanti load via API
  // String? selectedRestaurant;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input Title
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Input Content
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            // Placeholder untuk Recommendations (optional)
            // Misalnya nanti kita tambah dropdown untuk pilih rekomendasi:
            // DropdownButton<String>(
            //   value: selectedRestaurant,
            //   hint: const Text('Select Recommendation'),
            //   items: restaurants.map((r) {
            //     return DropdownMenuItem(
            //       value: r,
            //       child: Text(r),
            //     );
            //   }).toList(),
            //   onChanged: (val) {
            //     setState(() {
            //       selectedRestaurant = val;
            //     });
            //   },
            // ),

            const Spacer(),
            // Tombol Submit
            ElevatedButton(
              onPressed: () {
                final title = _titleController.text.trim();
                final content = _contentController.text.trim();

                if (title.isEmpty || content.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Title and Content are required')),
                  );
                  return;
                }

                // Buat objek post baru
                final newPost = {
                  'title': title,
                  'content': content,
                  'created_at': DateTime.now().toString(), // Dummy data
                  'recommendations': [], // Nanti bisa tambah
                };

                // Kembalikan data ini ke ForumPage
                Navigator.pop(context, newPost);
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
