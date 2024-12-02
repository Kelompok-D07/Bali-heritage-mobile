// To parse this JSON data, do
//
//     final storiesEntry = storiesEntryFromJson(jsonString);

import 'dart:convert';

List<StoriesEntry> storiesEntryFromJson(String str) => List<StoriesEntry>.from(json.decode(str).map((x) => StoriesEntry.fromJson(x)));

String storiesEntryToJson(List<StoriesEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class StoriesEntry {
    String model;
    String pk;
    Fields fields;

    StoriesEntry({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory StoriesEntry.fromJson(Map<String, dynamic> json) => StoriesEntry(
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
    String image;
    String description;

    Fields({
        required this.name,
        required this.image,
        required this.description,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        name: json["name"],
        image: json["image"],
        description: json["description"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "image": image,
        "description": description,
    };
}
