import 'dart:convert';
import 'package:bali_heritage/Homepage/models/Product.dart';
import 'package:bali_heritage/Homepage/models/Restaurant.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RestaurantPage extends StatefulWidget {
  final String restaurantName; // This now represents the restaurant ID

  const RestaurantPage({super.key, required this.restaurantName});

  @override
  _RestaurantPageState createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage> {
  late Future<RestaurantData> _restaurantDataFuture;

  @override
  void initState() {
    super.initState();
    _restaurantDataFuture = fetchRestaurantData(widget.restaurantName);
  }

  Future<RestaurantData> fetchRestaurantData(String restaurantId) async {
    final response = await http.post(
      Uri.parse('http://localhost:8000/get-restaurant-flutter/'),
      body: json.encode({'restaurant_name': restaurantId}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Parse the restaurant and products from the response
      final restaurantData = data['data']['restaurant'];
      final productsData = data['data']['products'];

      // Map the products data to your Product model
      List<Product> products = productFromJson(json.encode(productsData));

      // Return both restaurant and products
      return RestaurantData(
        restaurant: Restaurant.fromJson(restaurantData),
        products: products,
      );
    } else {
      throw Exception('Failed to load restaurant data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: const Text(
          'Store Details',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<RestaurantData>(
        future: _restaurantDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          } else {
            final restaurantData = snapshot.data!;
            return ListView(
              children: [
                // Restaurant Banner
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.orangeAccent, Colors.white],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Placeholder for logo
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.orange,
                        child: const Icon(
                          Icons.store,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        restaurantData.restaurant.fields.name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        restaurantData.restaurant.fields.description,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '📍 ${restaurantData.restaurant.fields.location}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.orange,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Products Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Products',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: restaurantData.products.length,
                        itemBuilder: (context, index) {
                          final product = restaurantData.products[index];
                          return Card(
                            elevation: 5,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              title: Text(
                                product.fields.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'Rp ${product.fields.price}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.orange,
                                ),
                              ),
                              leading: Icon(
                                Icons.shopping_basket,
                                color: Colors.orangeAccent,
                              ),
                              tileColor: Colors.white,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

class RestaurantData {
  final Restaurant restaurant;
  final List<Product> products;

  RestaurantData({required this.restaurant, required this.products});
}
