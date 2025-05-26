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

  // Tính tổng giá của sản phẩm
  double get totalItemPrice => price * quantity;

  // Chuyển đổi CartItem thành Map
  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'product_name': productName,
      'product_image': imageUrl,
      'price': price,
      'quantity': quantity,
      'is_select': isSelect,  // Nếu muốn lưu trạng thái isSelect
    };
  }

  // Khởi tạo CartItem từ Map
  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      productId: map['product_id'] ?? '', // Dự phòng giá trị null
      productName: map['product_name'] ?? '',
      imageUrl: map['product_image'] ?? '', // Dự phòng giá trị null
      price: (map['price'] as num?)?.toDouble() ?? 0.0, // Dự phòng giá trị null
      quantity: map['quantity'] ?? 1, // Dự phòng nếu quantity không có
      isSelect: map['is_select'] ?? false, // Dự phòng nếu isSelect không có
    );
  }
}