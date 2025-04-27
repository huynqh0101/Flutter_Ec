class CartItem {
  final String productId;
  final String productName;
  final String imageUrl;
  final double price;
  int quantity;
  bool isSelect;

  CartItem({
    required this.productId,
    required this.productName,
    required this.imageUrl,
    required this.price,
    this.quantity = 1,
    this.isSelect = false,
  });

  double get totalItemPrice => price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'product_name': productName,
      'product_image': imageUrl,
      'price': price,
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
        productId: map['product_id'],
        productName: map['product_name'],
        imageUrl: map['imageUrl'],
        price: map['price'],
        quantity: map['quantity'],
        );
  }
}
