import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String review_id;
  final String product_id;
  final String review_title;
  final String review_content;
  final String user_id;
  final double rating;
  final int review_time;
  final String review_name;

  Review({
    required this.review_id,
    required this.review_title,
    required this.review_content,
    required this.user_id,
    required this.rating,
    required this.product_id,
    required this.review_time,
    required this.review_name
  });

  factory Review.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Review(
      review_id: doc.id,
      product_id: data['item_amazon_id'] ?? '',
      user_id: data['user_amazon_id'] ?? '',
      review_content: data['review_text'] ?? '',
      review_title: data['summary'] ?? '',
      rating: data['rating'] ?? 0.0,
      review_time: data['review_time'] ?? 0,
      review_name: data['user_name'],
    );
  }
}

