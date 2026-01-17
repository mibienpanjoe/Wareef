class Category {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final String? createdAt;
  final String? updatedAt;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['image'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'image': imageUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
