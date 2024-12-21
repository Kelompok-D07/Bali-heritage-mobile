import 'package:flutter/material.dart';
import 'forum_models.dart';
import 'restaurant_search_page.dart';

class ForumEditPage extends StatefulWidget {
  final ForumPost post;

  const ForumEditPage({Key? key, required this.post}) : super(key: key);

  @override
  State<ForumEditPage> createState() => _ForumEditPageState();
}

class _ForumEditPageState extends State<ForumEditPage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late List<Restaurant> selectedRestaurants;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post.title);
    _contentController = TextEditingController(text: widget.post.content);
    selectedRestaurants = List.from(widget.post.recommendations);
  }

  void _update() {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and content are required')),
      );
      return;
    }

    final updatedPost = ForumPost(
      id: widget.post.id,
      title: _titleController.text,
      content: _contentController.text,
      author: widget.post.author,
      createdAt: widget.post.createdAt,
      totalLikes: widget.post.totalLikes,
      hasLiked: widget.post.hasLiked,
      recommendations: selectedRestaurants,
    );

    Navigator.pop(context, updatedPost);
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
        title: const Text('Edit Post'),
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
                  child: const Text('Edit Recommendations'),
                ),
                const SizedBox(width: 16),
                Text('Selected: ${selectedRestaurants.length}'),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _update,
              child: const Text('Update'),
            )
          ],
        ),
      ),
    );
  }
}
