import 'package:flutter/material.dart';
import 'package:bali_heritage/Baliloka_stories/models/stories_entry.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'dart:convert'; // Untuk base64 encoding
import 'dart:io'; // Untuk membaca file
import 'package:image_picker_web/image_picker_web.dart';
import 'package:image_picker/image_picker.dart'; // Untuk memilih file gambar
import 'dart:io' show File; // Untuk platform non-web
import 'package:flutter/foundation.dart'; // Untuk mendeteksi platform

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
  String _imageBase64 = "";

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.story.name);
    descriptionController = TextEditingController(text: widget.story.description);
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<String> pickImageAndConvertToBase64() async {
    try {
      if (kIsWeb) {
        // Gunakan ImagePickerWeb untuk web
        final image = await ImagePickerWeb.getImageAsBytes();
        if (image != null) {
          return base64Encode(image);
        } else {
          return "";
        }
      } else {
        // Gunakan ImagePicker untuk platform non-web
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(source: ImageSource.gallery);

        if (pickedFile != null) {
          final bytes = await File(pickedFile.path).readAsBytes();
          return base64Encode(bytes);
        } else {
          return "";
        }
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
      return "";
    }
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
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: "Masukkan Judul Stories",
                      labelText: "Judul Stories",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "Judul tidak boleh kosong!";
                      }
                      return null;
                    },
                  ),
                ),

                // Input Deskripsi (Textarea untuk paragraf)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      hintText: "Masukkan Deskripsi Stories",
                      labelText: "Deskripsi",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    ),
                    maxLines: 5, // Membuat area input teks besar
                    keyboardType: TextInputType.multiline,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "Deskripsi tidak boleh kosong!";
                      }
                      return null;
                    },
                  ),
                ),

                // Button Pilih Gambar
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      final base64Image = await pickImageAndConvertToBase64();

                      if (base64Image.isNotEmpty) {
                        setState(() {
                          _imageBase64 = base64Image;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Gambar berhasil dipilih."),
                        ));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Tidak ada gambar yang dipilih."),
                        ));
                      }
                    },
                    child: const Text("Pilih Gambar"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary, // Menggunakan warna sekunder dari tema
                      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      foregroundColor: Colors.white, // Warna teks tombol
                    ),
                  ),
                ),

                // Button Save
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          if (_imageBase64.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text("Harap pilih gambar sebelum menyimpan."),
                            ));
                            return;
                          }

                          final request = context.read<CookieRequest>();
                          final response = await request.postJson(
                            'https://muhammad-adiansyah-baliheritage.pbp.cs.ui.ac.id/stories/edit-flutter/${widget.story.id}/',
                            jsonEncode({
                              'name': nameController.text,
                              'image': 'data:image/png;base64,' + _imageBase64,
                              'description': descriptionController.text,
                            }),
                          );

                          if (context.mounted) {
                            if (response['status'] == 'success') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Story berhasil diperbarui!')),
                              );
                              // Mengembalikan data baru ke halaman sebelumnya
                              Navigator.pop(context, {
                                'id': widget.story.id,
                                'name': nameController.text,
                                'description': descriptionController.text,
                                'image': _imageBase64,
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Gagal memperbarui story.')),
                              );
                            }
                          }
                        }
                      },
                      child: const Text(
                        "Simpan Perubahan",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary, // Menggunakan warna utama dari tema
                        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
