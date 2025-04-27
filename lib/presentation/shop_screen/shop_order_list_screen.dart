import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'shop_order_model.dart';

Stream<List<ShopOrderModel>> getShopOrders() {
  final ordersRef = FirebaseFirestore.instance.collection('orders');

  return ordersRef
      .orderBy('createdAt', descending: true) // Sắp xếp đơn hàng theo ngày tạo (mới nhất trước)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      return ShopOrderModel.fromFirebase(doc);
    }).toList();
  });
}

class ShopOrderScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách đơn hàng của Shop'),
      ),
      body: StreamBuilder<List<ShopOrderModel>>(
        stream: getShopOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print(snapshot.error);
            return Center(child: Text('Có lỗi xảy ra!'));
          }

          final orders = snapshot.data ?? []; // Kiểm tra dữ liệu null và sử dụng danh sách rỗng nếu không có dữ liệu

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return ListTile(
                title: Text('Đơn hàng #${order.orderId}'),
                subtitle: Text('Tổng giá: ${order.totalPrice} VNĐ'),
                trailing: Text(order.status),
                onTap: () {
                  // Chuyển sang chi tiết đơn hàng khi nhấn vào item
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => OrderDetailScreen(orderId: order.orderId),
                  //   ),
                  // );
                },
              );
            },
          );
        },
      ),
    );
  }
}
