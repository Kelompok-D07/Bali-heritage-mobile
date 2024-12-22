  // To parse this JSON data, do
  //
  //     final forum = forumFromJson(jsonString);

// models/forum_models.dart
  import 'dart:convert';


  List<Forum> forumFromJson(String str) => List<Forum>.from(json.decode(str).map((x) => Forum.fromJson(x)));

  String forumToJson(List<Forum> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

  class Forum {
      String model;
      int pk;
      Fields fields;

      Forum({
          required this.model,
          required this.pk,
          required this.fields,
      });

      factory Forum.fromJson(Map<String, dynamic> json) => Forum(
          model: json["model"],
          pk: json["pk"],
          fields: Fields.fromJson(json["fields"]),
      );

      Map<String, dynamic> toJson() => {
          "model": model,
          "pk": pk,
          "fields": fields.toJson(),
      };
  }

  class Fields {
    String title;
    String content;
    int author;
    DateTime createdAt;
    List<dynamic> recommendations;
    List<int> likedBy; // field baru jika diperlukan
    String authorName; // field baru jika diperlukan
    int totalLikes; // Tambahkan ini untuk jumlah total like
    bool isLiked;    // Tambahkan ini untuk status like oleh pengguna saat ini

    Fields({
      required this.title,
      required this.content,
      required this.author,
      required this.createdAt,
      required this.recommendations,
      required this.likedBy,
      required this.authorName,
      this.totalLikes = 0,
      this.isLiked = false,
      
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
    title: json["title"],
    content: json["content"],
    author: json["author"],
    createdAt: DateTime.parse(json["created_at"]),
    recommendations: List<dynamic>.from(json["recommendations"].map((x) => x)),
    likedBy: json["liked_by"] == null 
            ? [] 
            : List<int>.from(json["liked_by"].map((x) => x)),
    authorName: json["author_username"],
    totalLikes: json["liked_by"] != null ? json["liked_by"].length : 0,
    // isLiked akan diatur di Flutter berdasarkan ID pengguna saat ini
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "content": content,
    "author": author,
    "created_at": createdAt.toIso8601String(),
    "recommendations": List<dynamic>.from(recommendations.map((x) => x)),
    "liked_by": List<dynamic>.from(likedBy.map((x) => x)),
    "author_username": authorName,
  };
}