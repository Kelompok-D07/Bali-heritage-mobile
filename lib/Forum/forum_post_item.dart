import 'package:flutter/material.dart';
import 'forum_models.dart';
import 'forum_utils.dart';
import 'forum_detail_page.dart';

class ForumPostItem extends StatelessWidget {
  final ForumPost post;
  final String searchQuery;
  final VoidCallback onToggleLike;

  const ForumPostItem({
    Key? key,
    required this.post,
    required this.searchQuery,
    required this.onToggleLike,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ambil excerpt dari content
    String excerpt = post.content;
    if (excerpt.length > 100) {
      excerpt = excerpt.substring(0, 100) + '...';
    }

    return Card(
      child: ListTile(
        title: RichText(
          text: highlightText(post.title, searchQuery),
        ),
        subtitle: RichText(
          text: highlightText(excerpt, searchQuery),
        ),
        trailing: IconButton(
          icon: Icon(
            post.hasLiked ? Icons.thumb_up : Icons.thumb_up_off_alt,
            color: post.hasLiked ? Colors.blue : Colors.grey,
          ),
          onPressed: onToggleLike,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ForumDetailPage(post: post),
            ),
          );
        },
      ),
    );
  }
}
