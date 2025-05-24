import 'package:untitled/model/address_model.dart';
import 'package:untitled/model/product.dart';
class ShopModel{
  String id;
  String name;
  String? description;
  String? logoUrl;
  int income;
  final List<String>? products;
  final List<String>? orders;
  final List<String>? vouchers;
  String? addressId;
  ShopModel({
    required this.id,
    required this.name,
    this.description,
    this.logoUrl,
    this.income = 0,
    this.products,
    this.orders,
    this.vouchers,
    this.addressId,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'logoUrl': logoUrl,
      'income': income,
      'products': products,
      'orders': orders,
      'vouchers': vouchers,
      'addressId': addressId,
    };
  }
  // Method to create ShopModel from Firestore Map
  factory ShopModel.fromMap(Map<String, dynamic> map) {
    return ShopModel(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      logoUrl: map['logoUrl'],
      income: map['income'] ?? 0,
      // products: List<String>.from(map['products'] ?? []),
      orders: List<String>.from(map['orders'] ?? []),
      vouchers: List<String>.from(map['vouchers'] ?? []),
      addressId: map['addressId'],
    );
  }
}