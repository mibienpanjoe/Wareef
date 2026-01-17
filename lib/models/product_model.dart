class Product {
  final String id;
  final String name;
  final String? categoryId;
  final int stockQuantity;
  final double price;
  final String? description;
  final String? imageUrl;
  final String? createdAt;
  final String? updatedAt;

  Product({
    required this.id,
    required this.name,
    this.categoryId,
    required this.stockQuantity,
    required this.price,
    this.description,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'],
      name: json['name'],
      categoryId: json['category'] is Map
          ? json['category']['_id']
          : json['category'],
      stockQuantity: json['stockQuantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
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
      'category': categoryId,
      'stockQuantity': stockQuantity,
      'price': price,
      'description': description,
      'image': imageUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
