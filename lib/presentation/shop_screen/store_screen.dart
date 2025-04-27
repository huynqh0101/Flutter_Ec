import 'package:flutter/material.dart';
import 'package:untitled/core/app_export.dart';
import 'package:untitled/model/product.dart';
import 'package:untitled/model/shop_model.dart';
import 'package:untitled/presentation/shop_screen/shop_order_list_screen.dart';
import 'package:untitled/services/product_service.dart';
import 'package:untitled/services/shop_service/shop_service.dart';

import '../../model/user.dart';
import 'addProduct.dart';
import 'productStoreItem.dart';

class StoreScreen extends StatefulWidget {
  final CustomUser user;

  const StoreScreen({super.key, required this.user});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  ShopService shopService = ShopService();
  late ShopModel shopModel;
  List<Product> products = [];
  Product? recentlyDeletedProduct; // Lưu sản phẩm vừa bị xóa

  bool loadShopModel = true;
  bool loadProducts = true;

  @override
  void initState() {
    super.initState();
    // getShop();
  }

  // Tải thông tin cửa hàng
  // Future<void> getShop() async {
  //   shopModel = await shopService.getShopById(widget.user.uid!);
  // }

  // Tải danh sách sản phẩm
  Future<void> getProducts() async {
    products = await ProductService().fetchProductsAndSortByCreatAt();
    setState(() {
      loadShopModel = false;
      loadProducts = false;
    });
  }

  // Hàm xóa sản phẩm
  Future<void> deleteProduct(String productId) async {
    // Tìm sản phẩm bị xóa và lưu lại
    recentlyDeletedProduct =
        products.firstWhere((product) => product.product_id == productId);
    products.removeWhere((product) => product.product_id == productId);

    setState(() {});

    // Xóa sản phẩm khỏi Firestore
    await ProductService().deleteProduct(productId);

    // Hiển thị Snackbar với nút Undo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Product "${recentlyDeletedProduct!.product_name}" deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            undoDelete();
          },
        ),
      ),
    );
  }


  Future<void> undoDelete() async {
    if (recentlyDeletedProduct != null) {
      // Thêm lại sản phẩm vào Firestore
      await ProductService().addProduct(recentlyDeletedProduct!);

      // Thêm lại sản phẩm vào danh sách
      setState(() {
        products.add(recentlyDeletedProduct!);
        recentlyDeletedProduct = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    getProducts();
    return Scaffold(
      appBar: AppBar(
        title: Text('Store'),
      ),
      body:
      Container(
        color: Colors.grey[150],
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Phần thông tin cửa hàng
                  // Container(
                  //   color: Colors.blue,
                  //   height: 100,
                  //   width: double.infinity,
                  //   child: Padding(
                  //     padding: const EdgeInsets.all(8.0),
                  //     child: Row(
                  //       children: [
                  //         CircleAvatar(),
                  //         SizedBox(width: 16),
                  //         Text(shopModel.name ?? 'name'),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  // SizedBox(height: 16),
                  // Phần đơn hàng (nếu có)
                  Container(
                    color: LightCodeColors().orangeA200,
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('Orders', style: CustomTextStyles.titleProductBlack,),
                              Spacer(),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ShopOrderScreen()));
                                },
                                child: Text('View all orders >', style: CustomTextStyles.bodyMediumDeeppurpleA200_1 ,),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Phần thêm sản phẩm
                  Container(
                    width: double.infinity,
                    color: LightCodeColors().orangeA200,
                    child: GestureDetector(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [Icon(Icons.add,), Text('Add new product', style: CustomTextStyles.titleProductBlack.copyWith(fontSize: 16),)],
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddProductScreen()),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  // Danh sách sản phẩm
                  loadProducts
                      ? Center(child: CircularProgressIndicator())
                      : Expanded(
                          child: ListView.builder(
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              return ProductItem(
                                product: products[index],
                                onDelete: deleteProduct,
                              );
                            },
                          ),
                        ),
                ],
              ),
            ),
    );
  }
}
