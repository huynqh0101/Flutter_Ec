import 'package:flutter/material.dart';
import 'package:untitled/core/app_export.dart';

import '../../model/Cart/cart_item.dart';
import '../../model/order/orders_model.dart';
import '../../routes/app_routes.dart';
import '../../services/my_order_service.dart';
import '../../services/auth_service.dart';
import '../../theme/custom_text_style.dart';
import '../../theme/theme_helper.dart';
import '../../widgets/custom_elevated_button.dart';

class MyOrderScreen extends StatelessWidget {
  MyOrderService myOrderService = MyOrderService();
  String userId = AuthService().getCurrentUser() == null
      ? ''
      : AuthService().getCurrentUser()!.uid;

  @override
  Widget build(BuildContext context) {
    return userId == ''
        ? Scaffold(
      body: Center(
        child: Text('No orders'),
      ),
    )
        : Scaffold(
      appBar: AppBar(
        backgroundColor: LightCodeColors().deepPurpleA200,
        title: Text(
          "My Order",
          style: CustomTextStyles.titleProductBlack
              .copyWith(color: Colors.white, fontSize: 18.h),
        ),
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.homeScreen)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Order List
          Expanded(
            child:
            buildOrderList(myOrderService.getOrdersByUserId(userId)),
          ),
        ],
      ),
    );
  }

  Widget buildOrderList(Future<List<OrdersModel>> futureOrders) {
    return FutureBuilder<List<OrdersModel>>(
      future: futureOrders,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error  : ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No orders found.'));
        } else {
          print('data khong rong');
          final orders = snapshot.data!;
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              return _buildOrderCard(orders[index]);
            },
          );
        }
      },
    );
  }

  Widget _buildTab(String text, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.deepPurple : Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrdersModel orderModel) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Brand and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "DEERMA",
                  style: CustomTextStyles.titleProductBlack
                      .copyWith(fontSize: 16.h),
                ),
                Text("Order delivered",
                    style: CustomTextStyles.bodySmallBlack900.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.h)),
              ],
            ),
            const SizedBox(height: 8),

            // Delivery Date and Status
            Row(
              children: [
                Icon(Icons.local_shipping, color: Colors.grey),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      orderModel.createdAt.toString(),
                      style: CustomTextStyles.bodySmallBlack900.copyWith(
                          color: Colors.black,
                          fontSize: 14.h,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Your Package Has Been Shipped.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Product List
            Column(
              children: [
                for (int i = 0; i < orderModel.productItems.length; i++)
                  _buildProductItem(orderModel.productItems[i]),
              ],
            ),

            const SizedBox(height: 8),

            // Total and Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${orderModel.productItems.length} items: \$${orderModel.totalPrice}",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black),
                ),
                CustomElevatedButton(
                  onPressed: () {},
                  height: 40.h,
                  width: 100.h,
                  text: 'Write review',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductItem(CartItem cartItem) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product Image
        Container(
          height: 60,
          width: 60,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: NetworkImage(cartItem.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),

        // Product Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cartItem.productName,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text(
                        "\$${cartItem.price}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Text("x${cartItem.quantity}"),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}