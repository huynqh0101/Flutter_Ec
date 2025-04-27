import 'package:flutter/material.dart';
import 'package:untitled/core/app_export.dart';
import 'package:untitled/presentation/cart_screen/cart_screen.dart';
import 'package:untitled/presentation/orders_screen/my_order_screen.dart';
import 'package:untitled/services/product_service.dart';
import 'package:untitled/widgets/custom_elevated_button.dart';

import '../../model/product.dart';
import '../../widgets/product_card.dart';
import '../detail_screen/detail_screen.dart';

class AfterOrder extends StatefulWidget {
  const AfterOrder({super.key});

  @override
  State<AfterOrder> createState() => _AfterOrderState();
}

class _AfterOrderState extends State<AfterOrder> {
  Future<List<Product>> fetchRelatedProducts() async {
    final products = await ProductService().fetchAllProducts();
    return products.take(20).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading:IconButton(

            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.homeScreen)
        ),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                color: Colors.deepPurpleAccent[200],
                child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.offline_pin_rounded,
                            color: LightCodeColors().orangeA200,
                            size: 80.h,
                          ),
                          SizedBox(
                            height: 8.h,
                          ),
                          Text(
                            'Thank you for your order!!',
                            style: CustomTextStyles.titleProductBlack
                                .copyWith(fontSize: 20.h),
                          ),
                          Text(
                            'You will receive updates in notifications.',
                            style: CustomTextStyles.bodySmallBlack900
                                .copyWith(fontSize: 14.h),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: CustomElevatedButton(
                              text: 'View order',
                              onPressed: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context)=> MyOrderScreen()));

                              },
                            ),
                          ),
                        ],
                      ),
                    )),
              ),
              Container(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: _buildRelatedProductItem(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRelatedProductItem() {
    return FutureBuilder<List<Product>>(
      future: fetchRelatedProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No related products found.'));
        } else {
          final relatedProducts = snapshot.data!;
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 20,
            itemBuilder: (context, index) {
              final product = relatedProducts[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProductDetailScreen(product: product),
                    ),
                  );
                },
                child: ProductCard(product),
              );
            },
          );
        }
      },
    );
  }
}