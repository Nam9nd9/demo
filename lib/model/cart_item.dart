class Item {
  final String productId;
  final int quantity;
  final double price;
  final double discount;

  Item({
    required this.productId,
    required this.quantity,
    required this.price,
    required this.discount,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      productId: json['product_id'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "product_id": productId,
      "quantity": quantity,
      "price": price,
      "discount": discount,
    };
  }
}
