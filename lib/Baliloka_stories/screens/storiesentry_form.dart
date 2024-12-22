import 'dart:convert'; // Untuk base64 encoding
import 'dart:io'; // Untuk membaca file
import 'package:image_picker_web/image_picker_web.dart';
import 'package:image_picker/image_picker.dart'; // Untuk memilih file gambar
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:bali_heritage/Baliloka_stories/screens/list_storiesentry.dart';
import 'dart:io' show File; // Untuk platform non-web
import 'package:flutter/foundation.dart'; // Untuk mendeteksi platform
import 'package:http/http.dart' as http;

Future<void> sendImage() async {
  try {
    var response = await http.post(
      Uri.parse('https://muhammad-adiansyah-baliheritage.pbp.cs.ui.ac.id/stories/create-flutter/'),
      headers: {
        'Content-Type': 'application/json', // Pastikan ini ditambahkan
      },
      body: '{"key": "value"}', // Sesuaikan dengan payload yang sesuai
    );

    if (response.statusCode == 200) {
      debugPrint('Success: ${response.body}');
    } else {
      debugPrint('Failed: ${response.statusCode}, ${response.body}');
    }
  } catch (e) {
    debugPrint('Error: $e');
  }
}


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


class StoriesEntryForm extends StatefulWidget {
  const StoriesEntryForm({super.key});

  @override
  State<StoriesEntryForm> createState() => _StoriesEntryFormState();
}

class _StoriesEntryFormState extends State<StoriesEntryForm> {
  final _formKey = GlobalKey<FormState>();
  String _name = "";
  String _description = "";
  String _imageBase64 = "";

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

                          final response = await request.postJson(  
                            "https://muhammad-adiansyah-baliheritage.pbp.cs.ui.ac.id/stories/create-flutter/",
                            jsonEncode(<String, String>{
                              'name': _name,
                              'image': 'data:image/png;base64,' + _imageBase64,
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



