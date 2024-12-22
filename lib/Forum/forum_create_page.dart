// lib/forum_create_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'dart:convert';

class ForumCreatePage extends StatefulWidget {
  const ForumCreatePage({Key? key}) : super(key: key);

  @override
  State<ForumCreatePage> createState() => _ForumCreatePageState();
}

class _ForumCreatePageState extends State<ForumCreatePage> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _content = '';

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final request = Provider.of<CookieRequest>(context, listen: false);

      // Siapkan data yang akan dikirim sebagai JSON
      final data = {
        'title': _title,
        'content': _content,
      };

      final jsonData = jsonEncode(data);
      final url = 'http://127.0.0.1:8000/forum/create_post_flutter/';
      print('Sending POST request to: $url'); // Debugging
      print('Data: $jsonData'); // Debugging

      try {
        // Kirim permintaan POST dengan data JSON
        final response = await request.postJson(url, jsonData);
        print('Create Post Response: $response'); // Debugging

        if (response['success'] == true) {
          Navigator.pop(context, true); // Kembali ke halaman forum dengan hasil sukses
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['error'] ?? 'Gagal membuat post.'))
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Buat Postingan Baru")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Input untuk judul
              TextFormField(
                decoration: const InputDecoration(labelText: 'Judul'),
                onSaved: (val) => _title = val ?? '',
                validator: (val) =>
                    val == null || val.isEmpty ? 'Judul wajib diisi' : null,
              ),
              // Input untuk konten
              TextFormField(
                decoration: const InputDecoration(labelText: 'Konten'),
                onSaved: (val) => _content = val ?? '',
                validator: (val) =>
                    val == null || val.isEmpty ? 'Konten wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              // Tombol untuk membuat postingan
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Buat'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
