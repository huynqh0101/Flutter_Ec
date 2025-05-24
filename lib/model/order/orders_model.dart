import 'package:cloud_firestore/cloud_firestore.dart';

import '../Cart/cart_item.dart';

class OrdersModel {
  final String? orderId; // ID đơn hàng
  final String? userId;
  final List<CartItem> productItems;
  final double totalPrice;
  final String status;
  final DateTime createdAt;

  OrdersModel({
    required this.orderId,
    required this.userId,
    required this.productItems,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
  });

  factory OrdersModel.fromJson(String id, Map<String, dynamic> json) {
    // Đảm bảo các trường đều có giá trị mặc định khi null
    final List<dynamic> items = json['orderItems'] ?? [];
    return OrdersModel(
      orderId: id,
      userId: json['userId'] ?? 'Unknown', // Dự phòng 'Unknown' nếu userId không có
      productItems: items.map((item) => CartItem.fromMap(item)).toList(),
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0, // Dự phòng 0.0 nếu totalPrice không có
      status: json['status'] ?? 'Pending', // Dự phòng 'Pending' nếu status không có
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(), // Dự phòng DateTime.now() nếu createdAt không có
    );
  }

  factory OrdersModel.fromFirebase(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final List<dynamic> items = data['orderItems'] ?? [];

    return OrdersModel(
      orderId: data['orderId'] ?? '', // Dự phòng nếu orderId không có
      userId: data['userId'] ?? 'Unknown', // Dự phòng nếu userId không có
      productItems: items.map((item) => CartItem.fromMap(item)).toList(),
      totalPrice: (data['totalPrice'] as num?)?.toDouble() ?? 0.0, // Dự phòng 0.0 nếu totalPrice không có
      status: data['status'] ?? 'Pending', // Dự phòng 'Pending' nếu status không có
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(), // Dự phòng DateTime.now() nếu createdAt không có
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'orderItems': productItems.map((item) => item.toMap()).toList(),
      'totalPrice': totalPrice,
      'status': status,
      'createdAt': createdAt,
      'orderId': orderId,
    };
  }
}