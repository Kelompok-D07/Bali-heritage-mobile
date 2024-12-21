// To parse this JSON data, do
//
//     final product = productFromJson(jsonString);

import 'dart:convert';

List<Product> productFromJson(String str) => List<Product>.from(json.decode(str).map((x) => Product.fromJson(x)));

String productToJson(List<Product> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Product {
    String model;
    int pk;
    Fields fields;

    Product({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory Product.fromJson(Map<String, dynamic> json) => Product(
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
    String name;
    String description;
    String price;
    String image;
    int category;
    String restaurantName;
    bool bookmarked;

    Fields({
        required this.name,
        required this.description,
        required this.price,
        required this.image,
        required this.category,
        required this.restaurantName,
        required this.bookmarked,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        name: json["name"],
        description: json["description"],
        price: json["price"],
        image: json["image"],
        category: json["category"],
        restaurantName: json["restaurant_name"],
        bookmarked: json["bookmarked"] ?? false,
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "description": description,
        "price": price,
        "image": image,
        "category": category,
        "restaurant_name": restaurantName,
        "bookmarked": bookmarked,
    };
}
