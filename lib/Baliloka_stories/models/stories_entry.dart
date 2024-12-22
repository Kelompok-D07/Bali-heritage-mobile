class StoriesEntry {
  String id; // Ubah tipe data ke String
  String name;
  String description;
  String image;

  StoriesEntry({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
  });

  factory StoriesEntry.fromJson(Map<String, dynamic> json) {
    return StoriesEntry(
      id: json["id"],
      name: json["name"],
      description: json["description"],
      image: json["image"],
    );
  }
}
