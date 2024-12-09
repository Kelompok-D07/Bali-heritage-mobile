import 'package:flutter/material.dart';
import 'forum_models.dart';
import 'forum_edit_page.dart';

class ForumDetailPage extends StatefulWidget {
  final ForumPost post;

  const ForumDetailPage({Key? key, required this.post}) : super(key: key);

  @override
  State<ForumDetailPage> createState() => _ForumDetailPageState();
}

class _ForumDetailPageState extends State<ForumDetailPage> {
  late ForumPost post;

  @override
  void initState() {
    super.initState();
    post = widget.post;
  }

  void _toggleLike() {
    setState(() {
      post.toggleLike();
    });
  }

  void _deletePost() {
    // Sementara: hapus post lokal saja (nanti panggil endpoint)
    Navigator.pop(context, {'deleted': true});
  }

  @override
  Widget build(BuildContext context) {
    bool isAuthor = true; // Asumsi sementara, nanti pakai logic user login
    return Scaffold(
      appBar: AppBar(
        title: Text(post.title),
        actions: [
          if (isAuthor)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ForumEditPage(post: post)),
                ).then((value) {
                  if (value != null && value is ForumPost) {
                    setState(() {
                      post = value;
                    });
                  }
                });
              },
            ),
          if (isAuthor)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Delete Post'),
                    content: const Text('Are you sure you want to delete this post?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _deletePost();
                        },
                        child: const Text('Delete'),
                      )
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('By: ${post.author}'),
            const SizedBox(height: 8),
            Text(post.content),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    post.hasLiked ? Icons.thumb_up : Icons.thumb_up_off_alt,
                    color: post.hasLiked ? Colors.blue : Colors.grey,
                  ),
                  onPressed: _toggleLike,
                ),
                Text('${post.totalLikes + (post.hasLiked ? 1 : 0)} Likes'),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Recommendations:'),
            ...post.recommendations.map((r) => Text('- ${r.name}')),
          ],
        ),
      ),
    );
  }
}
