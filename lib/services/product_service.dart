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
      QuerySnapshot snapshot =
          await _firestore.collection('amazon_products').limit(100).get();
      print('querry data thanh cong');

      //change
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching products: $e');
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

  Future<List<Product>> fetchProductsByCategory(String categoryId) async {
    try {
      final productsCollection =
          FirebaseFirestore.instance.collection('amazon_products');

      // Truy vấn sản phẩm theo category_id
      final querySnapshot = await productsCollection
          .where('category_id', isEqualTo: categoryId)
          .get();

      // Chuyển đổi dữ liệu thành danh sách Product
      return querySnapshot.docs
          .map((doc) => Product.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Failed to fetch products by category: $e');
      return [];
    }
  }

  Future<List<Product>> fetchProductsByName(String template) async {
    try {
      final productsCollection =
          FirebaseFirestore.instance.collection('amazon_products');

      // Chuyển template sang chữ thường để tìm kiếm không phân biệt chữ hoa, chữ thường
      final templateLowercase = template.toLowerCase();

      // Truy vấn sản phẩm theo tên chứa `template`
      final querySnapshot = await productsCollection
          .where('title', isGreaterThanOrEqualTo: templateLowercase)
          .where('title', isLessThanOrEqualTo: '$templateLowercase\uf8ff')
          .get();

      // Chuyển đổi dữ liệu thành danh sách Product
      return querySnapshot.docs
          .map((doc) => Product.fromFirestore(doc))
          .toList();
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
          .limit(8)
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

  //getSaleList
  Future<List<Product>> getSaleProductList() async {
    try {
      //top 5 rating
      final querySnapshot = await FirebaseFirestore.instance
          .collection('amazon_products')
          .orderBy('discount_percentage', descending: true)
          .limit(8)
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

  Future<Product> getProductById(String productId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('amazon_products').doc(productId).get();
      if (doc.exists) {
        print('lay dâata thanh cong');
        return Product.fromFirestore(doc);
      }
      return Product(
          discount_percentage: 1,
          discounted_price: 1,
          product_id: '1',
          product_name: 'product_name',
          category: 'category',
          about_product: 'about_product',
          actual_price: 1,
          rating: 1,
          rating_count: 1,
          img_link: 'img_link',
          brand: 'brand',
          related_product: []);
    } catch (e) {
      print('Error fetching product: $e');
      return Product(
          discount_percentage: 1,
          discounted_price: 1,
          product_id: '1',
          product_name: 'product_name',
          category: 'category',
          about_product: 'about_product',
          actual_price: 1,
          rating: 1,
          rating_count: 1,
          img_link: 'img_link',
          brand: 'brand',
          related_product: []);
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
