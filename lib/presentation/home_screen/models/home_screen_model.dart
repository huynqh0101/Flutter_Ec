import 'dart:async';

import 'package:untitled/core/app_export.dart';
import 'package:untitled/model/product.dart';
import 'package:untitled/services/product_service.dart';
import '../../../model/product.dart';
import 'banner_list_item_model.dart';
import 'category_list_item_model.dart';

class HomeScreenModel {
  final ProductService productService = ProductService();

  Future<List<Product>> getAllProductFirestore() async {
    final productList = await productService.fetchAllProducts();
    return productList;
  }

  List<BannerListItemModel> bannerList = [
    BannerListItemModel(image: "lib/assets/images/banner1.png"),
    BannerListItemModel(image: "lib/assets/images/banner2.png"),
  ];

  Future<List<Product>> getTrendingProductList() async {
    return productService.getTrendingProducts();
  }

  Future<List<Product>> getSaleProductList() async {
    return productService.getSaleProductList();
  }

  Future<List<Product>> recommendedProductList() async {
    if (getAllProductFirestore() != null) {
      final productList = await productService.fetchAllProducts();
      return productList.toList();
    }

    return [];
  }

  List<CategoryListItemModel> categoryList = [
    CategoryListItemModel(
        id: "Electronics",
        name: "Electronics",
        imageUrl: "lib/assets/icons/computer_and_accessories.svg"),
    CategoryListItemModel(
        id: "Home & Kitchen",
        name: "Home & Kitchen",
        imageUrl: "lib/assets/icons/home_and_kitchen.svg"),
    CategoryListItemModel(
        id: "Clothing",
        name: "Clothing",
        imageUrl: "lib/assets/icons/fashion_and_apparel.svg"),
    CategoryListItemModel(
        id: "Health & Personal Care",
        name: "Health Care",
        imageUrl: "lib/assets/icons/groceries.svg"),
    CategoryListItemModel(
        id: "Toys & Games",
        name: "Toys & Games",
        imageUrl: "lib/assets/icons/toys.svg"),
    CategoryListItemModel(
        id: "Musical Instruments",
        name: "Musical Instruments",
        imageUrl: "lib/assets/icons/books_and_media.svg"),
    CategoryListItemModel(
        id: "Sports & Outdoors",
        name: "Sports & Outdoors",
        imageUrl: "lib/assets/icons/groceries.svg"),
    CategoryListItemModel(
        id: "Office Products",
        name: "Office Products",
        imageUrl: "lib/assets/icons/groceries.svg"),
    CategoryListItemModel(
        id: "Cell Phones & Accessories",
        name: "Cell Phones",
        imageUrl: "lib/assets/icons/groceries.svg"),
  ];
}
