import 'package:flutter/material.dart';
import 'forum_models.dart';
import 'restaurant_search_page.dart';

class ForumCreatePage extends StatefulWidget {
  const ForumCreatePage({Key? key}) : super(key: key);

  @override
  State<ForumCreatePage> createState() => _ForumCreatePageState();
}

class _ForumCreatePageState extends State<ForumCreatePage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  List<Restaurant> selectedRestaurants = [];

  void _submit() {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and content are required')),
      );
      return;
    }

    // Buat post baru (dummy)
    final newPost = ForumPost(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      content: _contentController.text,
      author: 'current_user',
      createdAt: DateTime.now(),
      totalLikes: 0,
      hasLiked: false,
      recommendations: selectedRestaurants,
    );

    Navigator.pop(context, newPost);
  }

  void _openRestaurantSearch() async {
    final result = await Navigator.push<List<Restaurant>>(
      context,
      MaterialPageRoute(builder: (context) => const RestaurantSearchPage()),
    );
    if (result != null) {
      setState(() {
        selectedRestaurants = result;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Content'),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _openRestaurantSearch,
                  child: const Text('Add Recommendations'),
                ),
                const SizedBox(width: 16),
                Text('Selected: ${selectedRestaurants.length}'),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Submit'),
            )
          ],
        ),
      ),
    );
  }
}
