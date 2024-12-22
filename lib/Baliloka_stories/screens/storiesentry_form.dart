import 'dart:convert'; // Untuk base64 encoding
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:bali_heritage/Baliloka_stories/screens/list_storiesentry.dart';
import 'package:http/http.dart' as http;

Future<void> sendPostRequest(String name, String image, String description) async {
  try {
    // URL endpoint Django
    final url = Uri.parse("https://muhammad-adiansyah-baliheritage.pbp.cs.ui.ac.id/stories/create-flutter/");

    // Mengirim permintaan POST
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json", // Menentukan format data
      },
      body: jsonEncode({
        'name': name,
        'image': image,
        'description': description,
      }),
    );

    // Mengecek status respons
    if (response.statusCode == 200) {
      debugPrint("Response: ${response.body}"); // Menampilkan respons jika berhasil
    } else {
      debugPrint("Failed: ${response.statusCode}"); // Menampilkan status jika gagal
    }
  } catch (e) {
    debugPrint("Error: $e"); // Menangkap dan menampilkan kesalahan jika ada
  }
}

class StoriesEntryForm extends StatefulWidget {
  const StoriesEntryForm({super.key});

  @override
  State<StoriesEntryForm> createState() => _StoriesEntryFormState();
}

class _StoriesEntryFormState extends State<StoriesEntryForm> {
  final _formKey = GlobalKey<FormState>();
  String _name = "";
  String _description = "";
  String _imageUrl = ""; // Variabel untuk menyimpan URL gambar

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text('Form Tambah Stories'),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Input Judul Stories
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: "Masukkan Judul Stories",
                      labelText: "Judul Stories",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    ),
                    onChanged: (String? value) {
                      setState(() {
                        _name = value!;
                      });
                    },
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
                    onChanged: (String? value) {
                      setState(() {
                        _description = value!;
                      });
                    },
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "Deskripsi tidak boleh kosong!";
                      }
                      return null;
                    },
                  ),
                ),

                // Input URL Gambar
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: "Masukkan URL Gambar",
                      labelText: "URL Gambar",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    ),
                    onChanged: (String? value) {
                      setState(() {
                        _imageUrl = value!;
                      });
                    },
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "URL gambar tidak boleh kosong!";
                      } else if (!Uri.tryParse(value)!.hasAbsolutePath) {
                        return "URL gambar tidak valid!";
                      }
                      return null;
                    },
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
                          final response = await request.postJson(  
                            "https://muhammad-adiansyah-baliheritage.pbp.cs.ui.ac.id/stories/create-flutter/",
                            jsonEncode(<String, String>{
                              'name': _name,
                              'image': _imageUrl, // Mengirimkan URL gambar
                              'description': _description,
                            }),
                          );

                          if (context.mounted) {
                            if (response['status'] == 'success') {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                content: Text("Stories baru berhasil disimpan!"),
                              ));
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => StoriesEntryPage()),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                content: Text("Terdapat kesalahan, silakan coba lagi."),
                              ));
                            }
                          }
                        }
                      },
                      child: const Text(
                        "Simpan",
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
