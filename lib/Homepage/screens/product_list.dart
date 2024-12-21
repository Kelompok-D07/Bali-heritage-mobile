import 'package:bali_heritage/Homepage/screens/product_card.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:bali_heritage/widgets/left_drawer.dart';
import 'package:bali_heritage/Homepage/models/Product.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  late Future<List<Product>> _products;

  @override
  void initState() {
    super.initState();
    _products = fetchProducts();
  }

  Future<List<Product>> fetchProducts() async {
    final response =
        await http.get(Uri.parse('http://localhost:8000/get-products/')); // Update URL as needed
    if (response.statusCode == 200) {
      final List<Product> products = productFromJson(response.body);
      return products;
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<void> toggleBookmark(int productId) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/toggle-bookmark/'), // Update URL as needed
        body: jsonEncode({'product_id': productId}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['status'] == 'success') {
          setState(() {
            _products = fetchProducts(); // Refresh the product list
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update bookmark.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server error. Please try again later.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product List'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: FutureBuilder<List<Product>>(
        future: _products,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (snapshot.hasData) {
            final products = snapshot.data!;
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ProductCard(
                  product: product,
                  onToggleBookmark: () => toggleBookmark(product.pk),
                );
              },
            );
          } else {
            return const Center(child: Text('No products available.'));
          }
        },
      ),
    );
  }
}
