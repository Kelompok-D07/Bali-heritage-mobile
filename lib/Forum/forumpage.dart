import 'package:flutter/material.dart';
import 'forum_models.dart';
import 'forum_create_page.dart';
import 'forum_edit_page.dart';
import 'forum_utils.dart';

class ForumPage extends StatefulWidget {
  const ForumPage({Key? key}) : super(key: key);

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {

  List<ForumPost> allPosts = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDummyData();
  }

  void _loadDummyData() {
    // Data dummy awal
    allPosts = [
      ForumPost(
        id: '1',
        title: 'adwa',
        content: 'wada',
        author: 'husin.hidayatul',
        createdAt: DateTime(2024, 12, 07, 19, 32),
        totalLikes: 0,
        hasLiked: false,
        recommendations: [],
      ),
    ];
  }

  List<ForumPost> get filteredPosts {
    if (searchQuery.isEmpty) return allPosts;
    return allPosts.where((post) {
      return post.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
             post.content.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  void _toggleLike(ForumPost post) {
    setState(() {
      post.hasLiked = !post.hasLiked;
      // Pada integrasi sungguhan, totalLikes akan dari server
      // Disini, karena dummy, kita asumsikan totalLikes tidak berubah kecuali user like/unlike
      // Jika user like dan sebelumnya belum like:
      if (post.hasLiked) {
        // misal totalLikes++ jika diinginkan
      } else {
        // misal totalLikes-- jika diinginkan, tapi pastikan tidak negatif
      }
    });
  }
//////////////////////////////////////////////////////
  Future<void> _createPost() async { 
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ForumCreatePage()),
    );
    if (result != null && result is ForumPost) {
      setState(() {
        allPosts.insert(0, result); // tambahkan post baru di atas
      });
    }
  }

  Future<void> _editPost(ForumPost post) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ForumEditPage(post: post)),
    );
    if (result != null && result is ForumPost) {
      // Update post di list
      setState(() {
        final index = allPosts.indexWhere((p) => p.id == post.id);
        if (index != -1) {
          allPosts[index] = result;
        }
      });
    }
  }

  void _deletePost(ForumPost post) {
    // Delete langsung dari list
    setState(() {
      allPosts.removeWhere((p) => p.id == post.id);
    });
  }
//////////////////////////////////////////////////////
  Widget _buildPostCard(ForumPost post) {
    // Format waktu
    final dateString = "${post.createdAt.year}-${post.createdAt.month.toString().padLeft(2,'0')}-${post.createdAt.day.toString().padLeft(2,'0')} ${post.createdAt.hour.toString().padLeft(2,'0')}:${post.createdAt.minute.toString().padLeft(2,'0')}";

    // Highlight title dan content jika ada searchQuery
    final titleSpan = highlightText(post.title, searchQuery);
    final contentSpan = highlightText(post.content, searchQuery);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                children: [titleSpan],
              ),
            ),
            const SizedBox(height: 8),
            // Content
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                children: [contentSpan],
              ),
            ),
            const SizedBox(height: 8),
            // By author on datetime
            Text(
              "By ${post.author} on $dateString",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            // Like count & Edit & Delete row
            Row(
              children: [
                // Like
                InkWell(
                  onTap: () => _toggleLike(post),
                  child: Row(
                    children: [
                      Icon(
                        Icons.favorite,
                        color: post.hasLiked ? Colors.red : Colors.blueGrey,
                      ),
                      const SizedBox(width: 4),
                      Text("${post.totalLikes} likes", style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Edit
                InkWell(
                  onTap: () => _editPost(post),
                  child: Row(
                    children: [
                      const Icon(Icons.edit, color: Colors.green),
                      const SizedBox(width: 4),
                      const Text("Edit", style: TextStyle(fontSize: 14, color: Colors.green)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Delete
                InkWell(
                  onTap: () => _deletePost(post),
                  child: Row(
                    children: [
                      const Icon(Icons.close, color: Colors.red),
                      const SizedBox(width: 4),
                      const Text("Delete", style: TextStyle(fontSize: 14, color: Colors.red)),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final posts = filteredPosts;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical:16.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Forum
              const Text(
                "Forum",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Search bar + Buttons
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) {
                        setState(() {
                          searchQuery = val;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      // Implementasikan fungsi search jika diperlukan
                    },
                    child: const Text("Search"),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _createPost,
                    child: const Text("New Post"),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // List Posts
              if (posts.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text('No forum posts available.'),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return _buildPostCard(post);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
