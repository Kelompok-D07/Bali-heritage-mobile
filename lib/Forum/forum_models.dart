import 'package:flutter/foundation.dart';

class ForumPost {
  final String id;
  final String title;
  final String content;
  final String author; // username author
  final DateTime createdAt;
  final int totalLikes;
  bool hasLiked;
  final List<Restaurant> recommendations;

  ForumPost({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.createdAt,
    required this.totalLikes,
    required this.hasLiked,
    required this.recommendations,
  });

  // Dummy method to simulate toggling like
  void toggleLike() {
    hasLiked = !hasLiked;
  }
}

class Restaurant {
  final String id;
  final String name;

  Restaurant({required this.id, required this.name});
}
