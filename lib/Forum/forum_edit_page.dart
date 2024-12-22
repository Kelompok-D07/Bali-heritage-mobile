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
  String? _selectedRecommendation;
  List<dynamic> _restaurants = [];

  @override
  void initState() {
    super.initState();
    _title = widget.post.fields.title;
    _content = widget.post.fields.content;
    _selectedRecommendation = widget.post.fields.recommendations.isNotEmpty
        ? widget.post.fields.recommendations[0].toString()
        : null;
    _fetchRestaurants();
  }

  Future<void> _fetchRestaurants() async {
    final request = Provider.of<CookieRequest>(context, listen: false);
    final url = 'http://127.0.0.1:8000/get-restaurants/';
    try {
      final response = await request.get(url);
      setState(() {
        _restaurants = response;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching restaurants: $e')),
      );
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final request = Provider.of<CookieRequest>(context, listen: false);

      final data = {
        'title': _title,
        'content': _content,
        'recommendations': [_selectedRecommendation],
      };

      final jsonData = jsonEncode(data);
      final url = 'http://127.0.0.1:8000/forum/edit_post_flutter/${widget.post.pk}/';
      try {
        final response = await request.postJson(url, jsonData);
        if (response['success'] == true) {
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['error'] ?? 'Gagal mengedit post.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
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
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'Judul'),
                onSaved: (val) => _title = val ?? '',
                validator: (val) =>
                    val == null || val.isEmpty ? 'Judul wajib diisi' : null,
              ),
              TextFormField(
                initialValue: _content,
                decoration: const InputDecoration(labelText: 'Konten'),
                onSaved: (val) => _content = val ?? '',
                validator: (val) =>
                    val == null || val.isEmpty ? 'Konten wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRecommendation,
                decoration: const InputDecoration(labelText: 'Pilih Restoran untuk Rekomendasi'),
                items: _restaurants.map<DropdownMenuItem<String>>((restaurant) {
                  return DropdownMenuItem<String>(
                    value: restaurant['pk'].toString(),
                    child: Text(restaurant['fields']['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRecommendation = value;
                  });
                },
              ),
              const SizedBox(height: 16),
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
