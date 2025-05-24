import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String? review_id;
  final String product_id;
  final String review_title;
  final String review_content;
  final String user_id;
  final double rating;
  final DateTime review_time;  // Chuyển đổi từ int thành DateTime
  final String review_name;

  Review({
    this.review_id,
    required this.review_title,
    required this.review_content,
    required this.user_id,
    required this.rating,
    required this.product_id,
    required this.review_time,
    required this.review_name,
  });

  factory Review.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Chuyển đổi review_time từ Unix timestamp (int) thành DateTime
    final reviewTime = data['review_time'] != null
        ? DateTime.fromMillisecondsSinceEpoch(data['review_time']) // Unix timestamp là tính bằng giây
        : DateTime.now(); // Nếu không có review_time, sử dụng thời gian hiện tại

    return Review(
      review_id: doc.id,
      product_id: data['item_amazon_id'] ?? '',
      user_id: data['user_amazon_id'] ?? '',
      review_content: data['review_text'] ?? '',
      review_title: data['summary'] ?? '',
      rating: data['rating'] ?? 0.0,
      review_time: reviewTime,
      review_name: data['user_name'] ?? '',
    );
  }
}