import 'package:flutter/material.dart';
import 'package:bali_heritage/Review/models/review_entry.dart';
import 'package:bali_heritage/widgets/left_drawer.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:bali_heritage/Review/screens/editreview_form.dart';

class ReviewEntryPage extends StatefulWidget {
  const ReviewEntryPage({super.key});

  @override
  State<ReviewEntryPage> createState() => _ReviewEntryPageState();
}

class _ReviewEntryPageState extends State<ReviewEntryPage> {
  Future<List<Review>> fetchReview(CookieRequest request) async {
    final response = await request.get('http://localhost:8000/review/myreview-json/');
    var data = response;

    List<Review> listReview = [];
    for (var d in data) {
      if (d != null) {
        listReview.add(Review.fromJson(d));
      }
    }
    return listReview;
  }

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
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("People's Review"),
      ),
      drawer: const LeftDrawer(),
      body: FutureBuilder(
        future: fetchReview(request),
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
                      builder: (BuildContext context, BoxConstraints constraints) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Row teratas -> Nama Restaurant di kiri + Tanggal di kanan
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Nama Restoran (lebih besar)
                                Expanded(
                                  child: Text(
                                    fields.restaurant,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18, // Lebih besar untuk highlight
                                    ),
                                  ),
                                ),
                                // Tanggal di kanan
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

                            // Nama User
                            Text(
                              fields.user,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(height: 4),

                            // Rating bintang
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

                            // Deretan tombol Edit/Delete
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (fields.user == request.jsonData['username']) ...[
                                  // Tombol Edit
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
                                          setState(() {});
                                        }
                                      });
                                    },
                                    child: const Text("Edit Review"),
                                  ),
                                  const SizedBox(width: 8),
                                  // Tombol Delete
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
                                          ) ??
                                          false;
                                      if (confirm) {
                                        final success = await deleteReview(request, review.pk);
                                        if (success) {
                                          setState(() {});
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
    );
  }

  /// Contoh sederhana pemformatan tanggal (sesuaikan dengan package intl jika mau lebih rapi).
  String _formatDate(String dateStr) {
    try {
      final dateTime = DateTime.parse(dateStr);
      return "${_monthName(dateTime.month)} ${dateTime.day}, ${dateTime.year}";
    } catch (e) {
      return dateStr;
    }
  }

  /// Helper nama bulan
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
