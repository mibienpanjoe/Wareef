class StockMovement {
  final String id;
  final String productId;
  final String? productName; // For display helper
  final String type; // 'IN' or 'OUT'
  final int quantity;
  final String? description;
  final String? createdAt;

  StockMovement({
    required this.id,
    required this.productId,
    this.productName,
    required this.type,
    required this.quantity,
    this.description,
    this.createdAt,
  });

  factory StockMovement.fromJson(Map<String, dynamic> json) {
    // Handle product field which might be populated (Map) or just ID (String)
    String pId = '';
    String? pName;

    if (json['product'] is Map) {
      pId = json['product']['_id'] ?? '';
      pName = json['product']['name'];
    } else {
      pId = json['product'] ?? '';
    }

    return StockMovement(
      id: json['_id'],
      productId: pId,
      productName: pName,
      type: json['type'],
      quantity: json['quantity'] ?? 0,
      description: json['description'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'product': productId,
      'type': type,
      'quantity': quantity,
      'description': description,
      'createdAt': createdAt,
    };
  }
}
