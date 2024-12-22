import 'package:flutter/material.dart';
import 'package:bali_heritage/Review/models/review_entry.dart';
import 'package:bali_heritage/widgets/left_drawer.dart';
import 'package:bali_heritage/Homepage/models/Restaurant.dart'; 
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:bali_heritage/Review/screens/editreview_form.dart';
import 'dart:convert';

class ReviewEntryPage extends StatefulWidget {
  const ReviewEntryPage({super.key});

  @override
  State<ReviewEntryPage> createState() => _ReviewEntryPageState();
}

class _ReviewEntryPageState extends State<ReviewEntryPage> {
  // Daftar restoran dan ID restoran terpilih
  List<Restaurant> _restaurants = [];
  String? _selectedRestaurantId; // null = "All"

  // Future yang menampung data review saat ini
  late Future<List<Review>> _futureReviews;

  late CookieRequest request;

  @override
  void initState() {
    super.initState();
    // Agar context sudah siap
    WidgetsBinding.instance.addPostFrameCallback((_) {
      request = context.read<CookieRequest>();

      // Ambil daftar restoran
      _fetchRestaurants();

      // Set default: menampilkan semua review (tanpa filter)
      _selectedRestaurantId = null; 
      _futureReviews = fetchReview(); 
      
      setState(() {});
    });
  }

  /// Ambil daftar restoran dari endpoint `/review/show-restaurant/`
  Future<void> _fetchRestaurants() async {
    final url = 'http://127.0.0.1:8000/review/show-restaurant/';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<Restaurant> restaurants = restaurantFromJson(response.body);
        setState(() {
          _restaurants = restaurants;
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  /// Ambil daftar review, bisa dengan filter restaurantId
  Future<List<Review>> fetchReview({String? restaurantId}) async {
    // Jika ada restaurantId, sertakan query param
    final queryString = (restaurantId != null) ? '?restaurant_id=$restaurantId' : '';
    final fullUrl = 'http://127.0.0.1:8000/review/myreview-json/$queryString';

    final response = await request.get(fullUrl);
    var data = response;

    List<Review> listReview = [];
    for (var d in data) {
      if (d != null) {
        listReview.add(Review.fromJson(d));
      }
    }
    return listReview;
  }

  /// Fungsi hapus review
  Future<bool> deleteReview(CookieRequest request, String pk) async {
    final url = 'http://localhost:8000/review/delete-review-flutter/$pk/';
    final response = await request.post(url, {});

    if (response['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review deleted successfully')),
      );
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete review: ${response['message']}'),
        ),
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("People's Review"),
      ),
      drawer: const LeftDrawer(),
      body: Column(
        children: [
          // Bagian atas: Dropdown (All + list resto) + Tombol Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Dropdown
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Pilih Restoran',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedRestaurantId,
                    items: [
                      // Item "All" (value = null)
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('All'), 
                      ),
                      // Sisanya: daftar resto dari _restaurants
                      ..._restaurants.map((resto) {
                        return DropdownMenuItem<String>(
                          value: resto.pk,
                          child: Text(resto.fields.name),
                        );
                      }).toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedRestaurantId = value; 
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),

                // Tombol Search
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (_selectedRestaurantId == null) {
                        // Pilihan "All" => tampilkan semua review
                        _futureReviews = fetchReview();
                      } else {
                        // Pilihan resto tertentu => fetch filter
                        _futureReviews = fetchReview(
                          restaurantId: _selectedRestaurantId,
                        );
                      }
                    });
                  },
                  child: const Text('Search'),
                ),
              ],
            ),
          ),

          // Expanded: menampilkan daftar review
          Expanded(
            child: FutureBuilder(
              future: _futureReviews,
              builder: (context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: Text(
                      'Belum ada Review.',
                      style: TextStyle(fontSize: 20),
                    ),
                  );
                } else {
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: snapshot.data.length,
                    itemBuilder: (_, index) {
                      final review = snapshot.data[index];
                      final fields = review.fields;

                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Nama restoran (kiri) + Tanggal (kanan)
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          fields.restaurant,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        _formatDate(fields.time.toString()),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  // User
                                  Text(
                                    fields.user,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),

                                  // Rating (bintang)
                                  Row(
                                    children: List.generate(
                                      fields.rating,
                                      (_) => const Icon(
                                        Icons.star,
                                        color: Colors.orange,
                                        size: 18,
                                      ),
                                    ),
                                  ),

                                  // Komentar
                                  if (fields.comment.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      fields.comment,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                  const SizedBox(height: 12),

                                  // Tombol Edit/Delete jika user == request.jsonData['username']
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (fields.user == request.jsonData['username']) ...[
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => EditReviewPage(review: review),
                                              ),
                                            ).then((value) {
                                              if (value == true) {
                                                // Refresh
                                                setState(() {
                                                  if (_selectedRestaurantId == null) {
                                                    _futureReviews = fetchReview();
                                                  } else {
                                                    _futureReviews = fetchReview(
                                                      restaurantId: _selectedRestaurantId,
                                                    );
                                                  }
                                                });
                                              }
                                            });
                                          },
                                          child: const Text("Edit Review"),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed: () async {
                                            bool confirm = await showDialog<bool>(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return AlertDialog(
                                                      title: const Text('Delete Review'),
                                                      content: const Text('Are you sure you want to delete this review?'),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () => Navigator.pop(context, false),
                                                          child: const Text('Cancel'),
                                                        ),
                                                        TextButton(
                                                          onPressed: () => Navigator.pop(context, true),
                                                          child: const Text('Delete'),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                ) ?? false;
                                            if (confirm) {
                                              final success = await deleteReview(request, review.pk);
                                              if (success) {
                                                setState(() {
                                                  if (_selectedRestaurantId == null) {
                                                    _futureReviews = fetchReview();
                                                  } else {
                                                    _futureReviews = fetchReview(
                                                      restaurantId: _selectedRestaurantId,
                                                    );
                                                  }
                                                });
                                              }
                                            }
                                          },
                                          child: const Text("Delete Review"),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Format tanggal, contoh: "Dec. 20, 2024"
  String _formatDate(String dateStr) {
    try {
      final dateTime = DateTime.parse(dateStr);
      return "${_monthName(dateTime.month)} ${dateTime.day}, ${dateTime.year}";
    } catch (e) {
      return dateStr;
    }
  }

  String _monthName(int month) {
    switch (month) {
      case 1:
        return 'Jan.';
      case 2:
        return 'Feb.';
      case 3:
        return 'Mar.';
      case 4:
        return 'Apr.';
      case 5:
        return 'May';
      case 6:
        return 'Jun.';
      case 7:
        return 'Jul.';
      case 8:
        return 'Aug.';
      case 9:
        return 'Sep.';
      case 10:
        return 'Oct.';
      case 11:
        return 'Nov.';
      case 12:
        return 'Dec.';
      default:
        return '';
    }
  }
}
