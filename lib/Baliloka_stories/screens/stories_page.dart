import 'package:flutter/material.dart';
import 'storiesentry_form.dart'; // Pastikan file ini benar
import 'list_storiesentry.dart'; // Pastikan file ini benar

class StoriesPage extends StatelessWidget {
  const StoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bali Stories'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to the Bali Stories'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigasi ke StoriesEntryPage saat tombol ditekan
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StoriesEntryPage(),
                  ),
                );
              },
              child: const Text('Go to Stories Entry Page'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigasi ke StoriesEntryForm saat tombol ditekan
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const StoriesEntryForm(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("Tambah Stories"),
      ),
    );
  }
}
