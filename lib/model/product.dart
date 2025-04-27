import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled/model/reviews.dart';

class Product {
  final String product_id,
      product_name,
      brand,
      about_product;


  final double actual_price, discounted_price, rating;
  final int rating_count, discount_percentage;
  final String img_link;

  final String category;
  final List<String> related_product;
  final List<Review> reviews;

  Product({
    required this.discount_percentage,
    required this.discounted_price,
    required this.product_id,
    required this.product_name,
    required this.category,
    required this.about_product,
    required this.actual_price,
    required this.rating,
    required this.rating_count,
    required this.img_link,
    required this.brand,
    required this.related_product,
    this.reviews = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'item_amazon_id': product_id,
      'title': product_name,

      'description': about_product,
      'price': actual_price,
      'rating': rating,
      'rating_count': rating_count,
      'discount_percentage': discount_percentage,
      'imUrl': img_link,

    };
  }


  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Product(
        discount_percentage: data['discount_percentage'] ?? 0,
        product_id: data['item_amazon_id'] ?? '',
        product_name: data['title'] ?? '',
        category: data['category'] ?? '',
        about_product: data['description'] ?? '',
        actual_price: data['price'] ?? 0.0,
        rating: data['rating'] ?? 0.0,
        rating_count: data['rating_count'] ?? 0,
        img_link: data['imUrl'] ?? '',
        brand: data['brand'] ?? '',
        related_product: List<String>.from(data['related'] ?? []),
        discounted_price: (data['price'] * (1 - data['discount_percentage'] / 100) * 100).roundToDouble() / 100
    );
  }



  Future<List<Product>> fetchRelatedProducts(String id) async {
    try {
      final productsCollection = FirebaseFirestore.instance.collection('amazon_products');
      List<Product> relatedProducts = [];

      // Chia nhỏ danh sách related_product thành các phần nhỏ, mỗi phần không quá 30 phần tử
      const maxBatchSize = 30;
      for (int i = 0; i < related_product.length; i += maxBatchSize) {
        final batch = related_product.sublist(i, i + maxBatchSize > related_product.length ? related_product.length : i + maxBatchSize);

        final querySnapshot = await productsCollection
            .where('item_amazon_id', whereIn: batch)
            .get();

        // Chuyển đổi dữ liệu thành danh sách Product và thêm vào danh sách kết quả
        relatedProducts.addAll(querySnapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
      }

      return relatedProducts;
    } catch (e) {
      print('Failed to fetch related products: $e');
      return [];
    }
  }


  Future<List<Review>> fetchTop5Reviews(String productId) async {
    try {

      final querySnapshot = await FirebaseFirestore.instance
          .collection('reviews')
          .where('item_amazon_id', isEqualTo: productId)  // Lọc theo product_id
          .orderBy('review_time', descending: true)  // Sắp xếp theo review_time mới nhất
          .limit(5)  // Giới hạn chỉ 5 review đầu tiên
          .get();

      return querySnapshot.docs.map((doc) => Review.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching reviews: $e');
      return [];
    }
  }

  Future<List<Review>> fetchAllReviews(String productId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('reviews')
          .where('item_amazon_id', isEqualTo: productId)  // Lọc theo product_id
          // .orderBy('review_time', descending: true)  // Sắp xếp theo review_time mới nhất
          .get();

      return querySnapshot.docs.map((doc) => Review.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching reviews: $e');
      return [];
    }
  }

}


