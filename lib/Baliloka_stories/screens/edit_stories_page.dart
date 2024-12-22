import 'package:flutter/material.dart';
import 'package:bali_heritage/Baliloka_stories/models/stories_entry.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class EditStoriesPage extends StatefulWidget {
  final StoriesEntry story;

  const EditStoriesPage({Key? key, required this.story}) : super(key: key);

  @override
  State<EditStoriesPage> createState() => _EditStoriesPageState();
}

class _EditStoriesPageState extends State<EditStoriesPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController imageController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.story.name);
    descriptionController = TextEditingController(text: widget.story.description);
    imageController = TextEditingController(text: widget.story.image);
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Story'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Input Judul Stories
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: "Masukkan Judul Stories",
                    labelText: "Judul Stories",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Judul tidak boleh kosong!";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // Input Deskripsi
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    hintText: "Masukkan Deskripsi Stories",
                    labelText: "Deskripsi",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Deskripsi tidak boleh kosong!";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // Input URL Gambar
                TextFormField(
                  controller: imageController,
                  decoration: InputDecoration(
                    hintText: "Masukkan URL Gambar",
                    labelText: "URL Gambar",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "URL gambar tidak boleh kosong!";
                    } else if (!Uri.tryParse(value)!.hasAbsolutePath) {
                      return "URL gambar tidak valid!";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // Button Save
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final request = context.read<CookieRequest>();
                      final response = await request.postJson(
                        'https://muhammad-adiansyah-baliheritage.pbp.cs.ui.ac.id/stories/edit-flutter/${widget.story.id}/',
                        {
                          'name': nameController.text,
                          'image': imageController.text, // Ambil input URL gambar
                          'description': descriptionController.text,
                        },
                      );

                      if (response['status'] == 'success') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Story berhasil diperbarui!')),
                        );
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Gagal memperbarui story.')),
                        );
                      }
                    }
                  },
                  child: const Text("Simpan Perubahan"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
