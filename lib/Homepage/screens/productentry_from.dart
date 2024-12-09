import 'dart:convert';
import 'package:bali_heritage/Homepage/models/Category.dart';
import 'package:bali_heritage/Homepage/models/Restaurant.dart';
import 'package:flutter/material.dart';
import 'package:bali_heritage/widgets/left_drawer.dart';
import 'package:bali_heritage/Homepage/screens/homepage.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class ProductEntryFormPage extends StatefulWidget {
  const ProductEntryFormPage({super.key});

  @override
  State<ProductEntryFormPage> createState() => _ProductEntryFormPageState();
}

class _ProductEntryFormPageState extends State<ProductEntryFormPage> {
  final _formKey = GlobalKey<FormState>();

  String _productName = '';
  String _productDescription = '';
  String _productPrice = '';
  String _productImage = '';
  String _productCategory = '';
  String _restaurantName = '';

  List<Category> _categories = [];
  List<Restaurant> _restaurants = [];

  Category? _selectedCategory;
  Restaurant? _selectedRestaurant;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchRestaurants();
  }

  Future<void> _fetchCategories() async {
    final request = context.read<CookieRequest>();
    final response = await request.get("http://localhost:8000/get-categories/");
    if (response['status'] == 'success') {
      setState(() {
        _categories = List<Category>.from(
            response['categories'].map((x) => Category.fromJson(x)));
      });
    }
  }

  Future<void> _fetchRestaurants() async {
    final request = context.read<CookieRequest>();
    final response = await request.get("http://localhost:8000/get-restaurants/");
    if (response['status'] == 'success') {
      setState(() {
        _restaurants = List<Restaurant>.from(
            response['restaurants'].map((x) => Restaurant.fromJson(x)));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Add New Product',
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                context,
                label: "Product Name",
                hint: "Enter product name",
                onChanged: (value) => _productName = value,
              ),
              _buildTextField(
                context,
                label: "Product Description",
                hint: "Enter product description",
                onChanged: (value) => _productDescription = value,
              ),
              _buildTextField(
                context,
                label: "Product Price",
                hint: "Enter product price",
                inputType: TextInputType.number,
                onChanged: (value) => _productPrice = value,
              ),
              _buildTextField(
                context,
                label: "Product Image URL",
                hint: "Enter product image URL",
                onChanged: (value) => _productImage = value,
              ),
              // Category Dropdown
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<Category>(
                  decoration: InputDecoration(
                    labelText: 'Select Category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  value: _selectedCategory,
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                      _productCategory = value?.fields.name ?? '';
                    });
                  },
                  items: _categories.map((Category category) {
                    return DropdownMenuItem<Category>(
                      value: category,
                      child: Text(category.fields.name),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                ),
              ),
              // Restaurant Dropdown
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<Restaurant>(
                  decoration: InputDecoration(
                    labelText: 'Select Restaurant',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  value: _selectedRestaurant,
                  onChanged: (value) {
                    setState(() {
                      _selectedRestaurant = value;
                      _restaurantName = value?.fields.name ?? '';
                    });
                  },
                  items: _restaurants.map((Restaurant restaurant) {
                    return DropdownMenuItem<Restaurant>(
                      value: restaurant,
                      child: Text(restaurant.fields.name),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a restaurant';
                    }
                    return null;
                  },
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          Theme.of(context).colorScheme.primary),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final response = await request.postJson(
                          "http://localhost:8000/create-product/",
                          jsonEncode({
                            "name": _productName,
                            "description": _productDescription,
                            "price": _productPrice,
                            "image": _productImage,
                            "category": _productCategory,
                            "restaurant_name": _restaurantName,
                          }),
                        );
                        if (context.mounted) {
                          if (response['status'] == 'success') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text("Product has been added successfully!"),
                              ),
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomePage(),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    "Something went wrong, please try again."),
                              ),
                            );
                          }
                        }
                      }
                    },
                    child: const Text(
                      "Save",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(BuildContext context,
      {required String label,
      required String hint,
      TextInputType inputType = TextInputType.text,
      required Function(String) onChanged}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        keyboardType: inputType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
        onChanged: (value) => onChanged(value),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "$label cannot be empty!";
          }
          return null;
        },
      ),
    );
  }
}
