import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:untitled/model/product.dart';

class ProductDataService {
  Future<List<Product>> loadProductsFromJson() async {
    try {
      // Đọc file JSON từ assets
      final jsonString = await rootBundle.loadString('lib/assets/data .json');
      final List<dynamic> jsonData = json.decode(jsonString);

      // Chuyển đổi JSON thành danh sách sản phẩm
      return jsonData.map((item) {
        if (item is Map<String, dynamic>) {
          try {
            return Product(
              product_id: item['product_id'] ?? '',
              product_name: item['product_name'] ?? '',
              brand: '',
              about_product: item['about_product'] ?? '',
              actual_price: item['actual_price'] is num ? (item['actual_price'] as num).toDouble() : 0.0,
              discounted_price: item['discounted_price'] is num ? (item['discounted_price'] as num).toDouble() : 0.0,
              rating: item['rating'] is num ? (item['rating'] as num).toDouble() : 0.0,
              rating_count: item['rating_count'] is int ? item['rating_count'] : 0,
              discount_percentage: item['discount_percentage'] is int
                  ? item['discount_percentage']
                  : (item['discount_percentage'] is String
                  ? int.tryParse(item['discount_percentage'].replaceAll('%', '')) ?? 0
                  : 0),
              img_link: item['img_link'] ?? '',
              category: item['category'] is List
                  ? (item['category'] as List).isNotEmpty ? (item['category'][0] ?? '') : ''
                  : (item['category'] ?? ''),
              related_product: [],
            );
          } catch (e) {
            print('Error parsing product: $e');
            return null;
          }
        }
        return null;
      }).whereType<Product>().toList();
    } catch (e) {
      print('Error loading products from JSON: $e');
      return [];
    }
  }
}