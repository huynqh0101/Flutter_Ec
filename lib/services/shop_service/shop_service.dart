import 'package:cloud_firestore/cloud_firestore.dart';

import '../../model/shop_model.dart';


class ShopService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection reference
  CollectionReference get _shopCollection => _firestore.collection('shops');

  /// Tạo shop mới
  Future<void> createShop(ShopModel shop) async {
    try {
      await _shopCollection.doc(shop.id).set(shop.toMap());
    } catch (e) {
      throw Exception('Lỗi khi tạo shop: $e');
    }
  }

  /// Lấy thông tin shop theo ID
  Future<ShopModel> getShopById(String shopId) async {
    try {
      DocumentSnapshot doc = await _shopCollection.doc(shopId).get();
      if (doc.exists) {
        return ShopModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return ShopModel(id: '', name: 'name'); // Nếu shop không tồn tại
    } catch (e) {
      throw Exception('Lỗi khi lấy thông tin shop: $e');
    }
  }

  /// Cập nhật thông tin shop
  Future<void> updateShop(String shopId, Map<String, dynamic> updates) async {
    try {
      await _shopCollection.doc(shopId).update(updates);
    } catch (e) {
      throw Exception('Lỗi khi cập nhật shop: $e');
    }
  }

  /// Xóa shop
  Future<void> deleteShop(String shopId) async {
    try {
      await _shopCollection.doc(shopId).delete();
    } catch (e) {
      throw Exception('Lỗi khi xóa shop: $e');
    }
  }

  /// Lấy danh sách tất cả các shop
  Future<List<ShopModel>> getAllShops() async {
    try {
      QuerySnapshot querySnapshot = await _shopCollection.get();
      return querySnapshot.docs.map((doc) {
        return ShopModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách shops: $e');
    }
  }

  Future<ShopModel> getShopByName(String name) async {
    try {
      QuerySnapshot querySnapshot = await _shopCollection.where('name', isEqualTo: name).get();
      if (querySnapshot.docs.isNotEmpty) {
        return ShopModel.fromMap(querySnapshot.docs.first.data() as Map<String, dynamic>);
      }
      return ShopModel(id: '', name: '');
    } catch (e) {
      throw Exception('Lỗi khi lấy thông tin shop: $e');
    }
  }
  Future<void> addProductToShop(String shopId, String productId) async {
    try {
      await _shopCollection.doc(shopId).update({
        'products': FieldValue.arrayUnion([productId])
      });
    } catch (e) {
      throw Exception('Lỗi khi thêm sản phẩm vào shop: $e');
    }
  }
  Future<ShopModel> getShopByProductId(String productId) async {
    try {
      QuerySnapshot querySnapshot = await _shopCollection.where('products', arrayContains: productId).get();
      if (querySnapshot.docs.isNotEmpty) {
        return ShopModel.fromMap(querySnapshot.docs.first.data() as Map<String, dynamic>);
      }
      return ShopModel(id: '', name: '');
    } catch (e) {
      throw Exception('Lỗi khi lấy thông tin shop: $e');
    }
  }
  Future<void> addVoucherToShop(String shopId, String voucherId) async {
    try {
      await _shopCollection.doc(shopId).update({
        'vouchers': FieldValue.arrayUnion([voucherId])
      });
    } catch (e) {
      throw Exception('Lỗi khi thêm voucher vào shop: $e');
    }
  }

  Future<void> addAddressToShop(String shopId, String addressId) async {
    try {
      await _shopCollection.doc(shopId).update({
        'addressId': addressId
      });
    } catch (e) {
      throw Exception('Lỗi khi thêm địa chỉ vào shop: $e');
    }
  }
}
