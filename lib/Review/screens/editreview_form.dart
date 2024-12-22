import 'package:bali_heritage/Review/models/review_entry.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class EditReviewPage extends StatefulWidget {
  final Review review;

  const EditReviewPage({super.key, required this.review});

  @override
  State<EditReviewPage> createState() => _EditReviewPageState();
}

class _EditReviewPageState extends State<EditReviewPage> {
  // Controller untuk menampung comment
  final _commentController = TextEditingController();

  // Simpan rating di variabel integer (untuk bintang)
  int _rating = 0;

  @override
  void initState() {
    super.initState();

    // Isi default value dari review yang mau diedit
    _commentController.text = widget.review.fields.comment;
    _rating = widget.review.fields.rating; // misal rating adalah integer
  }

  // Fungsi panggil endpoint Django
  Future<void> updateReview(
    CookieRequest request,
    String pk,
    String comment,
    String rating,
  ) async {
    final url = 'https://muhammad-adiansyah-baliheritage.pbp.cs.ui.ac.id/review/edit-review-flutter/$pk/';

    final response = await request.post(url, {
      'comment': comment,
      'rating': rating, // kirim rating sebagai string
    });

    if (response['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review updated successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update review')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Your Review'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0), // beri padding agar mirip card web
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label "Comment"
            const Text(
              'Comment',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),

            // TextFormField mirip "textarea"
            TextFormField(
              controller: _commentController,
              maxLines: 5, // lebih banyak agar menyerupai web
              decoration: InputDecoration(
                hintText: 'Write your comment here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Label "Rating"
            const Text(
              'Rating',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),

            // Deretan bintang untuk pilih rating
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.orange,
                    size: 32,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1; // rating 1..5
                    });
                  },
                );
              }),
            ),

            const SizedBox(height: 24),

            // Tombol Save
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, // misal warna oranye
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                onPressed: () async {
                  // Panggil fungsi update review ke server
                  await updateReview(
                    request,
                    widget.review.pk,
                    _commentController.text,
                    _rating.toString(),
                  );

                  // Setelah sukses, kembali (pop) dengan memberi tahu parent untuk refresh
                  if (!mounted) return;
                  Navigator.pop(context, true);
                },
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
