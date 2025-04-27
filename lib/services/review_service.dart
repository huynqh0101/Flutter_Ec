import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/reviews.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Hàm để lấy các đánh giá của một sản phẩm cụ thể
  Future<List<Review>> fetchReviewsForProduct(String productId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('reviews')
          .where('item_amazon_id', isEqualTo: productId)
          .get();

      return snapshot.docs.map((doc) => Review.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching reviews for product $productId: $e');
      return [];
    }
  }
}
