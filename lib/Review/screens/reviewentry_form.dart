import 'package:bali_heritage/widgets/left_drawer.dart';
import 'package:flutter/material.dart';
import 'package:bali_heritage/Homepage/models/restaurant.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:bali_heritage/Homepage/screens/homepage.dart';

class ReviewEntryFormPage extends StatefulWidget {
  const ReviewEntryFormPage({super.key});

  @override
  State<ReviewEntryFormPage> createState() => _ReviewEntryFormPageState();
}

class _ReviewEntryFormPageState extends State<ReviewEntryFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _comment = '';
  int _rating = 0;                    // akan diisi melalui bintang
  String? _selectedRestaurantId;
  List<Restaurant> _restaurants = [];

  @override
  void initState() {
    super.initState();
    _fetchRestaurants();
  }

  Future<void> _fetchRestaurants() async {
    final url = 'http://127.0.0.1:8000/review/show-restaurant/';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<Restaurant> restaurants = restaurantFromJson(response.body);
        setState(() {
          _restaurants = restaurants;
        });
      } else {
        // Handle error
      }
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Your Own Review'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0), // margin agar mirip card di web
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label "Comment"
              const Text(
                'Comment',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              // TextFormField sebagai "textarea"
              TextFormField(
                maxLines: 5, // lebih banyak baris agar seperti textarea
                decoration: InputDecoration(
                  hintText: "Write your comment here...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                onChanged: (String? value) {
                  setState(() {
                    _comment = value ?? '';
                  });
                },
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Comment tidak boleh kosong!";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Label "Rating"
              const Text(
                'Rating',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),

              // Deretan bintang (1-5) yang bisa diketuk
              Row(
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      // Jika index < _rating => bintang terisi, kalau tidak bintang kosong
                      index < _rating ? Icons.star : Icons.star_border,
                      color: Colors.orange,
                      size: 32, 
                    ),
                    onPressed: () {
                      setState(() {
                        _rating = index + 1; // rating = 1..5
                      });
                    },
                  );
                }),
              ),

              // Validasi rating (opsional, misal rating tidak boleh 0)
              if (_rating == 0)
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    'Silakan pilih rating 1–5!',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),

              const SizedBox(height: 16),

              // Label "Pilih Restoran"
              const Text(
                'Pilih Restoran',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                value: _selectedRestaurantId,
                items: _restaurants.map((restaurant) {
                  return DropdownMenuItem<String>(
                    value: restaurant.pk,
                    child: Text(restaurant.fields.name),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRestaurantId = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Silakan pilih restoran!";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Tombol "Save" 
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () async {
                    // Validasi form & rating
                    if (_formKey.currentState!.validate() && _rating > 0) {
                      final response = await request.postJson(
                        "http://127.0.0.1:8000/review/create-review-flutter/",
                        jsonEncode(<String, String>{
                          'comment': _comment,
                          'rating': _rating.toString(),
                          'restaurant': _selectedRestaurantId!,
                        }),
                      );
                      if (!mounted) return;
                      if (response['status'] == 'success') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Review baru berhasil disimpan!")),
                        );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HomePage()),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Terdapat kesalahan, silakan coba lagi."),
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  child: const Text(
                    "Save",
                    style: TextStyle(color: Colors.white),
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
