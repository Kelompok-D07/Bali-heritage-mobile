import 'package:bali_heritage/Homepage/screens/product_card.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:bali_heritage/widgets/left_drawer.dart';
import 'package:bali_heritage/Homepage/models/Product.dart';
import 'package:bali_heritage/Homepage/models/Category.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  late Future<List<Product>> _products;
  late Future<List<Category>> _categories;
  String selectedCategory = 'ALL'; // Default to 'ALL'

  @override
  void initState() {
    super.initState();
    // Jadinya _products dan _categories diinisialisasi dalam build biar bisa mendapatkan CookieRequest
  }

  // Notes: FetchProduct menggunakan CookieRequest agar memunculkan toggle bookmarked unik setiap user
  Future<List<Product>> fetchProducts(CookieRequest request, String category) async {
    final response = await request.get(
      'https://muhammad-adiansyah-baliheritage.pbp.cs.ui.ac.id/get-products-by-category/?category=$category', // Update URL as needed
    );
    List<Product> listProduct = [];
    for (var d in response) {
      if (d != null) {
        listProduct.add(Product.fromJson(d));
      }
    }
    return listProduct;
  }

  Future<void> deleteProduct(CookieRequest request, int productId) async {
  try {
    final response = await http.post(
      Uri.parse('https://muhammad-adiansyah-baliheritage.pbp.cs.ui.ac.id/delete-product-flutter/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': productId}),
    );

    if (response.statusCode == 200) {
      setState(() {
        _products = fetchProducts(request, selectedCategory); // Refresh product list
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product deleted successfully.'),
          duration: Duration(seconds: 1),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete product.')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('An error occurred. Please try again.')),
    );
  }
}

  Future<List<Category>> fetchCategories() async {
    final response = await http.get(Uri.parse('https://muhammad-adiansyah-baliheritage.pbp.cs.ui.ac.id/get-categories/')); // Update URL as needed
    if (response.statusCode == 200) {
      final List<Category> categories = categoryFromJson(response.body);
      return categories;
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<void> toggleBookmark(CookieRequest request, String productName) async {
    try {
      final response = await request.postJson(
        "https://muhammad-adiansyah-baliheritage.pbp.cs.ui.ac.id/bookmarks/toogle-bookmark/",
        jsonEncode(<String, String>{
          'product_name': productName,
        }),
      );

      if (response['status'] == 'success') {
        setState(() {
          _products = fetchProducts(request, selectedCategory); // Refresh the product list
        });
        String message = response['message'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 1),),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update bookmark.')),
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
    final request = context.watch<CookieRequest>(); // Akses CookieRequest

    // Inisialisasi future di sini menggunakan request
    _products = fetchProducts(request, selectedCategory);
    _categories = fetchCategories();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product List'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Column(
        children: [
          FutureBuilder<List<Category>>(
            future: _categories,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                final categories = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Pilih Kategori', // Change the label text as needed
                      border: OutlineInputBorder(),
                    ),
                    value: selectedCategory,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCategory = newValue!;
                        _products = fetchProducts(request ,selectedCategory); // Fetch filtered products
                      });
                    },
                    items: [
                      const DropdownMenuItem(
                        value: 'ALL',
                        child: Text('All Categories'),
                      ),
                      ...categories.map<DropdownMenuItem<String>>((category) {
                        return DropdownMenuItem<String>(
                          value: category.pk.toString(),
                          child: Text(category.fields.name),
                        );
                      }).toList(),
                    ],
                  ),
                );
              } else {
                return const Center(child: Text('No categories available.'));
              }
            },
          ),
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: _products,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  final products = snapshot.data!;
                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ProductCard(
                        product: product,
                        onToggleBookmark: () => toggleBookmark(request, product.fields.name),
                        onDelete: () => deleteProduct(request, product.pk), 
                      );
                    },
                  );
                } else {
                  return const Center(child: Text('No products available.'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
