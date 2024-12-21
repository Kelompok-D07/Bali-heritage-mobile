// To parse this JSON data, do
//
//     final bookmark = bookmarkFromJson(jsonString);

import 'dart:convert';

List<Bookmark> bookmarkFromJson(String str) => List<Bookmark>.from(json.decode(str).map((x) => Bookmark.fromJson(x)));

String bookmarkToJson(List<Bookmark> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Bookmark {
    String model;
    int pk;
    Fields fields;

    Bookmark({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory Bookmark.fromJson(Map<String, dynamic> json) => Bookmark(
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
    String user;
    int userId;
    String product;
    int productId;
    String image;
    String notes;
    String description;

    Fields({
        required this.user,
        required this.userId,
        required this.product,
        required this.productId,
        required this.image,
        required this.notes,
        required this.description,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        user: json["user"],
        userId: json["user_id"],
        product: json["product"],
        productId: json["product_id"],
        image: json["image"],
        notes: json["notes"],
        description: json["description"],
    );

    Map<String, dynamic> toJson() => {
        "user": user,
        "user_id": userId,
        "product": product,
        "product_id": productId,
        "image": image,
        "notes": notes,
        "description": description,
    };
}
