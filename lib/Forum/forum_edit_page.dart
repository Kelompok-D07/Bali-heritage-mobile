// lib/forum_edit_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'dart:convert';
import 'models/forum_models.dart';

class ForumEditPage extends StatefulWidget {
  final Forum post;
  const ForumEditPage({Key? key, required this.post}) : super(key: key);

  @override
  State<ForumEditPage> createState() => _ForumEditPageState();
}

class _ForumEditPageState extends State<ForumEditPage> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _content;

  @override
  void initState() {
    super.initState();
    _title = widget.post.fields.title;
    _content = widget.post.fields.content;
  }

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
      final url = 'http://127.0.0.1:8000/forum/edit_post_flutter/${widget.post.pk}/';
      print('Sending POST request to: $url'); // Debugging
      print('Data: $jsonData'); // Debugging

      try {
        // Kirim permintaan POST dengan data JSON
        final response = await request.postJson(url, jsonData);
        print('Edit Post Response: $response'); // Debugging

        if (response['success'] == true) {
          Navigator.pop(context, true); // Kembali ke halaman forum dengan hasil sukses
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['error'] ?? 'Gagal mengedit post.'))
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
      appBar: AppBar(title: const Text("Edit Post")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Input untuk judul
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'Judul'),
                onSaved: (val) => _title = val ?? '',
                validator: (val) =>
                    val == null || val.isEmpty ? 'Judul wajib diisi' : null,
              ),
              // Input untuk konten
              TextFormField(
                initialValue: _content,
                decoration: const InputDecoration(labelText: 'Konten'),
                onSaved: (val) => _content = val ?? '',
                validator: (val) =>
                    val == null || val.isEmpty ? 'Konten wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              // Tombol untuk menyimpan perubahan
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
