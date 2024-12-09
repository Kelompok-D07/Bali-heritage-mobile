import 'package:bali_heritage/Forum/forumpage.dart';
import 'package:flutter/material.dart';
// Pastikan penulisan jalur impor sesuai dengan struktur folder Anda


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bali Heritage'),
        actions: [
          IconButton(
            icon: const Icon(Icons.forum),
            onPressed: () {
              // Navigasi ke ForumPage
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ForumPage()),
              );
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Welcome to the Bali Heritage'),
      ),
    );
  }
}
