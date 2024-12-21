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
  // Buat controller untuk textfield
  final _commentController = TextEditingController();
  final _ratingController = TextEditingController();

  Future<void> updateReview(
    CookieRequest request,
    String pk,
    String comment,
    String rating,
    ) async {
      final url = 'http://localhost:8000/review/edit-review-flutter/$pk/';

      // Contoh: kirim data JSON ke Django
      final response = await request.post(url, {
        'comment': comment,
        'rating': rating,
      });

      if (response['status'] == 'success') {
        // Handle success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review updated successfully')),
        );
      } else {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update review')),
        );
      }

      
  }

  
  @override
  void initState() {
    super.initState();
    // Set default value di form sesuai review yang mau diedit
    _commentController.text = widget.review.fields.comment;
    _ratingController.text = widget.review.fields.rating.toString();
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Your Review'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'Comment',
              ),
              maxLines: 4,
            ),
            TextFormField(
              controller: _ratingController,
              decoration: const InputDecoration(
                labelText: 'Rating',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Panggil fungsi update review ke server
                await updateReview(
                  request,
                  widget.review.pk, // primary key review
                  _commentController.text,
                  _ratingController.text,
                );

                // Setelah sukses, kembali ke halaman sebelumnya atau refresh list
                if (!mounted) return;
                Navigator.pop(context, true);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
