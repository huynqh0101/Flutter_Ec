import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../firebase_options.dart';
import '../../model/product.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//read
  Future<List<Product>> fetchAllProducts() async {
    try {
      //querry
      QuerySnapshot snapshot = await _firestore.collection('amazon_products').limit(50).get();
      print('querry data thanh cong');

      //change
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }

  Future<Product> fetchProductById(String productId) async {
    try {
      // Query the specific product by ID
      DocumentSnapshot snapshot = await _firestore.collection('amazon_products').doc(productId).get();

      if (snapshot.exists) {
        print('Product found');
        // Return the product based on the data from Firestore
        return Product.fromFirestore(snapshot);
      } else {
        print('Product not found');
        throw Exception('Product not found');
      }
    } catch (e) {
      print('Error fetching product by ID: $e');
      // Throw the error to be handled by the caller
      throw Exception('Error fetching product: $e');
    }
  }



  Future<List<Product>> fetchRecommendedProducts(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      print("ccc");
      print(userDoc.data());

      // Kiểm tra nếu tài liệu tồn tại và trường 'recommended' không rỗng
      if (userDoc.exists) {
        final recommended = userDoc.data()?['recommended'] as List<dynamic>?;

        if (recommended != null && recommended.isNotEmpty) {
          final productsCollection = FirebaseFirestore.instance.collection('amazon_products');
          List<Product> allRecommendedProducts = [];

          // Chia nhỏ danh sách recommended thành các phần nhỏ, mỗi phần không quá 30 phần tử
          const maxBatchSize = 30;
          for (int i = 0; i < recommended.length; i += maxBatchSize) {
            // Xác định phạm vi đúng của phần con
            final batch = recommended.sublist(i, i + maxBatchSize > recommended.length ? recommended.length : i + maxBatchSize);

            final querySnapshot = await productsCollection
                .where('item_amazon_id', whereIn: batch)
                .get();

            // Chuyển đổi dữ liệu thành danh sách Product và thêm vào danh sách kết quả
            allRecommendedProducts.addAll(querySnapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
          }

          // Trả về danh sách tất cả các sản phẩm đã tìm được
          return allRecommendedProducts;
        }
      }

      // Nếu 'recommended' rỗng hoặc không tồn tại, trả về danh sách sản phẩm ngẫu nhiên
      return fetchAllProducts();
    } catch (e) {
      print('Failed to fetch recommended products: $e');
      return [];
    }
  }


  Future<List<Product>> fetchProductsByCategory({
    required String categoryId,
    required int limit,
    DocumentSnapshot? lastDocument,
  }) async {
    Query query = FirebaseFirestore.instance
        .collection('amazon_products')
        .where('category', isEqualTo: categoryId)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final querySnapshot = await query.get();
    return querySnapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
  }

  Future<List<Product>> fetchProductsByName(String template) async {
    try {
      final productsCollection = FirebaseFirestore.instance.collection('amazon_products');

      // Chuyển template sang chữ thường để so sánh với lower_title
      final templateLowercase = template.toLowerCase();

      // Truy vấn sản phẩm theo lower_title chứa `templateLowercase` và giới hạn 10 sản phẩm
      final querySnapshot = await productsCollection
          .where('lower_title', isGreaterThanOrEqualTo: templateLowercase)
          .where('lower_title', isLessThanOrEqualTo: '$templateLowercase\uf8ff')
          .get();

      // Chuyển đổi dữ liệu thành danh sách Product
      return querySnapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    } catch (e) {
      print('Failed to fetch products by name: $e');
      return [];
    }
  }

  Future<List<Product>> fetch10ProductsByName(String template) async {
    try {
      final productsCollection = FirebaseFirestore.instance.collection('amazon_products');

      // Chuyển template sang chữ thường để so sánh với lower_title
      final templateLowercase = template.toLowerCase();

      // Truy vấn sản phẩm theo lower_title chứa `templateLowercase` và giới hạn 10 sản phẩm
      final querySnapshot = await productsCollection
          .where('lower_title', isGreaterThanOrEqualTo: templateLowercase)
          .where('lower_title', isLessThanOrEqualTo: '$templateLowercase\uf8ff')
          .limit(20) // Giới hạn 10 sản phẩm
          .get();

      // Chuyển đổi dữ liệu thành danh sách Product
      return querySnapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    } catch (e) {
      print('Failed to fetch products by name: $e');
      return [];
    }
  }


  //getTrendingLists
  Future<List<Product>> getTrendingProducts() async {
    try {
      //top 5 rating
      final querySnapshot = await FirebaseFirestore.instance
          .collection('amazon_products')
          .orderBy('rating_count', descending: true)
          .limit(20)
          .get();

      List<Product> trendingProducts = querySnapshot.docs.map((doc) {
        return Product.fromFirestore(doc);
      }).toList();

      return trendingProducts;
    } catch (e) {
      print('Error fetching trending products: $e');
      return [];
    }
  }

  Future<List<Product>> fetchProductsAndSortByCreatAt() async {
    try {
      //querry
      QuerySnapshot snapshot = await _firestore
          .collection('amazon_products')
          .orderBy('created_at', descending: true)
          .limit(100)
          .get();
      print('sap xep theo thoi gian tao');
      //change
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }

  //getSaleList
  Future<List<Product>> getSaleProductList() async {
    try {
      //top 5 rating
      final querySnapshot = await FirebaseFirestore.instance
          .collection('amazon_products')
          .orderBy('discount_percentage', descending: true)
          .limit(20)
          .get();

      List<Product> saleProducts = querySnapshot.docs.map((doc) {
        return Product.fromFirestore(doc);
      }).toList();


      return saleProducts;
    } catch (e) {
      print('Error fetching sale products: $e');
      return [];
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      // Thêm sản phẩm vào Firestore và lấy document ID
      DocumentReference docRef =
      await _firestore.collection('amazon_products').add({
        ...product.toMap(),
        'created_at': FieldValue.serverTimestamp(),
      });
      // Lấy product_id là ID của document vừa thêm
      String productId = docRef.id;
      // Cập nhật lại product_id trong Firestore
      await _firestore.collection('amazon_products').doc(productId).update({
        'item_amazon_id': productId,
      });
      print("Product added with ID: $productId\n"
          "Product updated with name: ${product.product_name}");
    } catch (e) {
      print("Error adding product: $e");
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('amazon_products').doc(productId).delete();
    } catch (e) {
      print('Error deleting product: $e');
    }
  }
  Future<void> addCreatedAtToAllProducts() async {
    try {
      // Lấy tất cả các document trong collection `products`
      QuerySnapshot snapshot =
      await _firestore.collection('amazon_products').limit(100).get();
      int i = 0;
      // Lặp qua từng document
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        // Cập nhật trường `created_at` với thời gian hiện tại
        await _firestore.collection('amazon_products').doc(doc.id).update({
          'created_at': FieldValue.serverTimestamp(),
        });
        print('da cap nhat xog $i sp :  ${doc.id}');
        i++;
      }
      print("All products updated with 'created_at' field.");
    } catch (e) {
      print("Error updating products: $e");
    }
  }

}
