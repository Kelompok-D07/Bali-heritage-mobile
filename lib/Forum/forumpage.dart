// lib/Forum/forumpage.dart

import 'dart:convert';
import 'package:bali_heritage/Homepage/screens/restaurant_page.dart';
import 'package:bali_heritage/widgets/left_drawer.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'models/forum_models.dart';
import 'package:bali_heritage/Homepage/models/Restaurant.dart';
import 'forum_create_page.dart';
import 'forum_edit_page.dart';
import 'forum_utils.dart';

class ForumPage extends StatefulWidget {
  const ForumPage({Key? key}) : super(key: key);

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final request = context.read<CookieRequest>();

    // Fungsi untuk mengambil semua postingan forum
    Future<List<Forum>> fetchForums(CookieRequest request) async {
      final url = 'http://127.0.0.1:8000/forum/json/';
      print('Fetching forums from: $url');

      final response = await request.get(url);

      List<Forum> listForum = [];
      for (var d in response) {
        if (d != null) {
          listForum.add(Forum.fromJson(d));
        }
      }
      return listForum;
    }

    // Fungsi untuk mengambil daftar restoran
    Future<List<Restaurant>> fetchRestaurants(CookieRequest request) async {
      final url = 'http://127.0.0.1:8000/get-restaurants/';
      print('Fetching restaurants from: $url');

      final response = await request.get(url);

      List<Restaurant> listRestaurant = [];
      for (var d in response) {
        if (d != null) {
          listRestaurant.add(Restaurant.fromJson(d));
        }
      }
      return listRestaurant;
    }

    // Fungsi untuk toggle like pada postingan
    Future<void> _toggleLike(int postId) async {
      final url = 'http://127.0.0.1:8000/forum/like_post_flutter/$postId/';
      print('Sending POST request to: $url');

      try {
        final response = await request.postJson(url, jsonEncode({}));
        print('Like Response: $response');

        if (response['success'] == true) {
          setState(() {}); // Refresh data setelah toggle like
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['liked'] == true
                  ? 'Post liked!'
                  : 'Post unliked!'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['error'] ?? 'Failed to like post.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }

    // Fungsi untuk menyaring postingan berdasarkan query pencarian
    List<Forum> _filterPosts(List<Forum> posts) {
      if (searchQuery.isEmpty) return posts;
      return posts.where((post) {
        return post.fields.title
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()) ||
               post.fields.content
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase());
      }).toList();
    }

    // Fungsi untuk membuat postingan baru
    Future<void> _createPost() async {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ForumCreatePage()),
      );
      if (result == true) {
        setState(() {}); // Refresh data setelah postingan baru dibuat
      }
    }

    // Fungsi untuk mengedit postingan
    Future<void> _editPost(Forum post) async {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ForumEditPage(post: post)),
      );
      if (result == true) {
        setState(() {}); // Refresh data setelah postingan diedit
      }
    }

    // Fungsi untuk menghapus postingan
    Future<void> _deletePost(int postId) async {
      final url = 'http://127.0.0.1:8000/forum/delete_post_flutter/$postId/';
      print('Deleting post with ID: $postId');

      try {
        final response = await request.postJson(url, jsonEncode({}));
        print('Delete Response: $response');

        if (response['success'] == true) {
          setState(() {}); // Refresh data setelah postingan dihapus
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post deleted successfully.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['error'] ?? 'Failed to delete post.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }

    // Fungsi untuk filter daftar restoran berdasarkan PK yang ada di post.fields.recommendations
    List<Restaurant> _filterRecommendedRestaurants(
        Forum post, List<Restaurant> allRestaurants) {
      // post.fields.recommendations adalah List<dynamic> berisi PK restoran (String UUID).
      // Bisa langsung memeriksa apakah PK (restaurant.pk) ada dalam list.
      return allRestaurants.where((restaurant) {
        return post.fields.recommendations.contains(restaurant.pk);
      }).toList();
    }

    // Widget untuk membangun tampilan kartu postingan
    Widget _buildPostCard(Forum post, List<Restaurant> allRestaurants) {
      // Dapatkan daftar restoran yang direkomendasikan
      final recommendedRestaurants = _filterRecommendedRestaurants(post, allRestaurants);

      // Format tanggal
      final dateString =
          "${post.fields.createdAt.year}-"
          "${post.fields.createdAt.month.toString().padLeft(2, '0')}-"
          "${post.fields.createdAt.day.toString().padLeft(2, '0')} "
          "${post.fields.createdAt.hour.toString().padLeft(2, '0')}:"
          "${post.fields.createdAt.minute.toString().padLeft(2, '0')}";

      return Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul dengan highlight
              RichText(
                text: highlightText(
                  post.fields.title,
                  searchQuery,
                  defaultStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Konten dengan highlight
              RichText(
                text: highlightText(
                  post.fields.content,
                  searchQuery,
                  defaultStyle: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(height: 8),

              // Informasi penulis dan tanggal
              Text(
                "By ${post.fields.authorName} on $dateString",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // Bagian rekomendasi restoran - TAMPILKAN HANYA JIKA recommendedRestaurants TIDAK KOSONG
              if (recommendedRestaurants.isNotEmpty) ...[
                const Text(
                  "Recommendations:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: recommendedRestaurants.map((restaurant) {
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RestaurantPage(
                              restaurantName: restaurant.pk,
                            ),
                          ),
                        );
                      },
                      child: Chip(
                        label: Text(
                          restaurant.fields.name,
                          style: const TextStyle(fontSize: 14),
                        ),
                        backgroundColor: Colors.blue.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],

              // Baris untuk Like, Edit, dan Delete
              Row(
                children: [
                  // Like
                  InkWell(
                    onTap: () => _toggleLike(post.pk),
                    child: Row(
                      children: [
                        Icon(
                          Icons.favorite,
                          color: post.fields.isLiked ? Colors.red : Colors.blueGrey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${post.fields.totalLikes}",
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Edit
                  InkWell(
                    onTap: () => _editPost(post),
                    child: Row(
                      children: const [
                        Icon(Icons.edit, color: Colors.green),
                        SizedBox(width: 4),
                        Text(
                          "Edit",
                          style: TextStyle(fontSize: 14, color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Delete
                  InkWell(
                    onTap: () => _deletePost(post.pk),
                    child: Row(
                      children: const [
                        Icon(Icons.close, color: Colors.red),
                        SizedBox(width: 4),
                        Text(
                          "Delete",
                          style: TextStyle(fontSize: 14, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // Widget utama ForumPage
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forum'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Baris untuk Search dan Tombol New Post
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
                      // Implementasi fitur search jika diperlukan
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

              // FutureBuilder untuk mengambil dan menampilkan postingan & restoran
              Expanded(
                child: FutureBuilder<List<dynamic>>(
                  future: Future.wait([
                    fetchForums(request),
                    fetchRestaurants(request),
                  ]),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      print('Error: ${snapshot.error}');
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      print('No data available.');
                      return const Center(child: Text('No forum posts available.'));
                    } else {
                      final forums = snapshot.data![0] as List<Forum>;
                      final restaurants = snapshot.data![1] as List<Restaurant>;

                      // Filter post jika ada search query
                      final filteredForums = _filterPosts(forums);

                      if (filteredForums.isEmpty) {
                        print('No matching posts found.');
                        return const Center(child: Text('No matching posts found.'));
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          // Pakai setState agar rebuild
                          setState(() {});
                        },
                        child: ListView.builder(
                          itemCount: filteredForums.length,
                          itemBuilder: (context, index) {
                            final post = filteredForums[index];
                            return _buildPostCard(post, restaurants);
                          },
                        ),
                      );
                    }
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
