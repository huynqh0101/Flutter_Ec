import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled/model/Cart/cart_item.dart';


class ShopOrderModel {
  final String orderId; // ID đơn hàng (lấy từ Firestore document ID)
  final DateTime createdAt; // Thời gian tạo đơn hàng
  final String userId; // ID người dùng đã đặt đơn hàng
  final List<CartItem> productItems; // Danh sách các sản phẩm trong đơn hàng
  final double totalPrice; // Tổng giá trị đơn hàng
  final String status; // Trạng thái đơn hàng

  ShopOrderModel({
    required this.orderId,
    required this.createdAt,
    required this.userId,
    required this.productItems,
    required this.totalPrice,
    required this.status,
  });

  // Hàm factory để tạo đối tượng từ Firebase
  factory ShopOrderModel.fromFirebase(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Chuyển đổi mảng orderItems thành CartItem
    final List<dynamic> items = data['orderItems'] ?? [];

    return ShopOrderModel(
      orderId: doc.id, // Lấy ID của tài liệu Firestore làm orderId
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userId: data['userId'] ?? 'Unknown', // Mặc định 'Unknown' nếu không có dữ liệu userId
      productItems: items.map((item) => CartItem.fromMap(item)).toList(),
      totalPrice: (data['totalPrice'] as num?)?.toDouble() ?? 0.0,
      status: data['status'] ?? 'Pending', // Mặc định 'Pending' nếu không có dữ liệu status
    );
  }

  // Chuyển đối tượng thành Map để lưu vào Firestore
  Map<String, dynamic> toJson() {
    return {
      'orderItems': productItems.map((item) => item.toMap()).toList(),
      'totalPrice': totalPrice,
      'status': status,
      'createdAt': createdAt,
      'userId': userId,
    };
  }
}
