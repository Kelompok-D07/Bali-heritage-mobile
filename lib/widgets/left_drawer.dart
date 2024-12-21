import 'package:bali_heritage/Bookmarks/screens/bookmarks.dart';
import 'package:bali_heritage/Homepage/screens/product_list.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; 
import 'dart:convert';

import 'package:bali_heritage/Homepage/screens/homepage.dart';
import 'package:bali_heritage/authentication/login.dart';  // Import ProductListPage
import 'package:bali_heritage/Homepage/screens/productentry_from.dart'; //
import 'package:bali_heritage/Review/screens/reviewentry_form.dart';  // Import Review Form
import 'package:bali_heritage/Review/screens/list_reviewform.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  Future<void> _logout(BuildContext context) async {
    try {
      final url = Uri.parse('http://localhost:8000/auth/logout/'); // Replace with your API endpoint
      final response = await http.post(url); // Send POST request to logout endpoint

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['status'] == true) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseBody['message'])),
          );

          // Navigate to LoginPage
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logout failed. Please try again.')),
          );
        }
      } else {
        // Handle error response
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server error. Please try again later.')),
        );
      }
    } catch (e) {
      // Handle exceptions
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
            ),
            child: Center(
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home, color: Theme.of(context).colorScheme.primary),
            title: const Text('Home'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.list, color: Theme.of(context).colorScheme.primary),
            title: const Text('Product List'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProductListPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.add_box, color: Theme.of(context).colorScheme.primary),
            title: const Text('Add Product'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProductEntryFormPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.rate_review, color: Theme.of(context).colorScheme.primary),
            title: const Text('Add Your Review'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReviewEntryFormPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.preview, color: Theme.of(context).colorScheme.primary),
            title: const Text("See People's Review"),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ReviewEntryPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.list, color: Theme.of(context).colorScheme.primary),
            title: const Text('Bookmarks'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BookmarkPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.primary),
            title: const Text('Logout'),
            onTap: () async {
              await _logout(context); // Call the logout function
            },
          ),
        ],
      ),
    );
  }
}