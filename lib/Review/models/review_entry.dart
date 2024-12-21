// To parse this JSON data, do
//
//     final review = reviewFromJson(jsonString);

import 'dart:convert';

List<Review> reviewFromJson(String str) => List<Review>.from(json.decode(str).map((x) => Review.fromJson(x)));

String reviewToJson(List<Review> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Review {
    String model;
    String pk;
    Fields fields;

    Review({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory Review.fromJson(Map<String, dynamic> json) => Review(
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
    int rating;
    String comment;
    DateTime time;
    String restaurant;

    Fields({
        required this.user,
        required this.rating,
        required this.comment,
        required this.time,
        required this.restaurant,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        user: json["user"],
        rating: json["rating"],
        comment: json["comment"],
        time: DateTime.parse(json["time"]),
        restaurant: json["restaurant"],
    );

    Map<String, dynamic> toJson() => {
        "user": user,
        "rating": rating,
        "comment": comment,
        "time": "${time.year.toString().padLeft(4, '0')}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')}",
        "restaurant": restaurant,
    };
}
