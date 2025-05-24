import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled/model/order/orders_model.dart';
import 'package:untitled/services/order_service.dart';

class MyOrderService {
  final CollectionReference ordersCollection = FirebaseFirestore.instance.collection('orders');

  // Method to get orders by user ID
  Future<List<OrdersModel>> getOrdersByUserId(String userId) async {
    final ordersRef = FirebaseFirestore.instance.collection('orders');
    final query = ordersRef.where('userId', isEqualTo: userId);

    try {
      final querySnapshot = await query.get();
      for (var doc in querySnapshot.docs) {
        print('abc\n ${doc.id} => ${doc.data()}');
      }
    } catch (e) {
      print('Error getting documents: $e');
    }

    return OrdersService().getOrdersByUserId(userId);
  }

  // New method to check if the user has purchased a specific product
  Future<bool> hasUserPurchasedProduct(String userId, String productId) async {
    try {
      // Query orders where userId matches and any orderItem has the specified product_id
      final querySnapshot = await ordersCollection
          .where('userId', isEqualTo: userId)
          .get();

      // Loop through orders to check if any order contains the product_id
      for (var doc in querySnapshot.docs) {
        final orderData = doc.data() as Map<String, dynamic>;
        final orderItems = orderData['orderItems'] as List<dynamic>;

        // Check if any orderItem contains the given product_id
        for (var item in orderItems) {
          if (item['product_id'] == productId) {
            print('User has purchased the product.');
            return true;
          }
        }
      }

      print('User has not purchased the product.');
      return false;
    } catch (e) {
      print('Error checking if user has purchased the product: $e');
      return false;
    }
  }
}