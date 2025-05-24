import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled/core/app_export.dart';
import 'package:untitled/model/address_model.dart';
import 'package:untitled/model/order/orders_model.dart';
import 'package:untitled/model/user.dart';
import 'package:untitled/presentation/cart_screen/cart_screen.dart';
import 'package:untitled/presentation/orders_screen/after_order.dart';
import 'package:untitled/presentation/orders_screen/edit_info.dart';
import 'package:untitled/services/address_service/address_repository.dart';
import 'package:untitled/services/cart_service.dart';
import 'package:untitled/services/order_service.dart';
import 'package:untitled/services/user_service.dart';
import 'package:untitled/widgets/custom_elevated_button.dart';

import '../../model/Cart/cart_item.dart';
import '../../services/stripe_service.dart';
import '../../widgets/custom_drop_down.dart';

class OrderScreen extends StatefulWidget {
  final List<CartItem> items;

  const OrderScreen({
    required this.items,
  });

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  String _paymentMethod = 'COD';
  late Future<CustomUser> customUser;
  String userId = '';
  late List<CartItem> listSelect;
  late double sum;
  String? _selectedDeliveryOption;
  double _shipPrice = 0;
  OrdersService ordersService = OrdersService();
  late AddressModel addressModel;
  late CartService cartService;
  String? province;
  String? district;
  String? ward;
  DateTime now = DateTime.now();

  @override
  void initState() {
    super.initState();

    userId = AuthService().getCurrentUser()!.uid;

    customUser = ProfileService().getUserProfile(userId);
    listSelect = widget.items;
    sum = calculateTotal();
    cartService = CartService();
    _getAddress();
  }

  double calculateTotal() {
    return listSelect.fold(0, (previousValue, item) {
      return previousValue + (item.quantity * item.price);
    });
  }

  Future<void> _getAddress() async {
    CustomUser currentUser = await customUser;
    if (currentUser.addressId != null) {
      final address =
      await AddressRepository().getAddressById(currentUser.addressId!);
      setState(() {
        province = address!.province;
        district = address.district;
        ward = address.ward;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pay'),
        backgroundColor: LightCodeColors().deepPurpleA200,
      ),
      body: Container(
        color: Color(0xFFD9D9D9),
        child: SingleChildScrollView(
          child: Column(
            children: [
              FutureBuilder<CustomUser>(
                future: customUser,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data == null) {
                    return Center(child: Text('No data available'));
                  }
                  if (snapshot.hasData) {
                    final user = snapshot.data!;
                    _getAddress();
                    return Container(
                      height: 100.h,
                      width: double.maxFinite,
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.only(left: 8.h, top: 8.h),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              color: LightCodeColors().orangeA200,
                            ),
                            SizedBox(
                              width: 2.h,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      user.name!,
                                      style: CustomTextStyles.titleProductBlack
                                          .copyWith(fontSize: 24.h),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(user.phone!),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(province ?? ''),
                                    SizedBox(
                                      width: 2.h,
                                    ),
                                    Text(district ?? ''),
                                    SizedBox(
                                      width: 2.h,
                                    ),
                                    Text(ward ?? '')
                                  ],
                                )
                              ],
                            ),
                            Spacer(),
                            Center(
                              child: IconButton(
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditInfo(
                                          user: user,
                                        ),
                                      ),
                                    );

                                    if (result == true) {
                                      setState(() {
                                        customUser = ProfileService()
                                            .getUserProfile(userId);
                                      });
                                    }
                                  },
                                  icon: Icon(Icons.chevron_right_sharp)),
                            )
                          ],
                        ),
                      ),
                    );
                  } else {
                    return const Center(child: Text('No data found'));
                  }
                },
              ),
              SizedBox(
                height: 14.h,
              ),
              Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            color: LightCodeColors().orangeA200,
                          ),
                          SizedBox(
                            width: 4.h,
                          ),
                          Text(
                            'Order summary',
                            style: CustomTextStyles.titleProductBlack,
                          )
                        ],
                      ),
                      SizedBox(
                        height: 14.h,
                      ),
                      SizedBox(
                        height: 100.h * listSelect.length,
                        child: ListView.builder(
                            itemCount: listSelect.length,
                            itemBuilder: (context, index) {
                              final item = listSelect[index];

                              return ListTile(
                                leading: CustomImageView(
                                  imagePath: item.imageUrl,
                                ),
                                title: Text(
                                  item.productName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: CustomTextStyles.titleProductBlack,
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'quantity : ${item.quantity}',
                                      style: CustomTextStyles
                                          .bodyMediumBluegray100,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          '\$${item.price}',
                                          style: CustomTextStyles
                                              .labelLargePrimary
                                              .copyWith(fontSize: 18),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              );
                            }),
                      ),
                      Row(
                        children: [
                          Spacer(),
                          Text('${listSelect.length} items: '),
                          Text(
                            '\$${sum}',
                            style: CustomTextStyles.labelLargePrimary,
                          ),
                          SizedBox(
                            width: 14.h,
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 14.h,
              ),
              Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.fire_truck,
                            color: LightCodeColors().orangeA200,
                          ),
                          SizedBox(
                            width: 4.h,
                          ),
                          Text(
                            'Delivery options',
                            style: CustomTextStyles.titleProductBlack,
                          ),
                        ],
                      ),
                      SizedBox(height: 8.0),
                      _buildDeliveryOption('Priority', 5,
                          'Receive from ${now.day + 1}-${now.month}-${now.year}'),
                      _buildDeliveryOption('Standard', 3,
                          'Receive from ${now.day+ 2}-${now.month}-${now.year}'),
                      _buildDeliveryOption('Saver', 2,
                          'Receive from ${now.day + 3}-${now.month}-${now.year}'),
                    ],
                  ),
                ),
              ),

              SizedBox(
                height: 16,
              ),
              //Payment method
              Container(
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.payments_sharp,
                              color: LightCodeColors().orangeA200,
                            ),
                            SizedBox(
                              width: 2.h,
                            ),
                            Text(
                              'Payment method',
                              style: CustomTextStyles.titleProductBlack,
                            ),
                          ],
                        ),
                        SizedBox(height: 8.0),
                        _buildPaymentMethod(),
                      ],
                    ),
                  )),
              SizedBox(
                height: 16.h,
              ),

              //Payment detail
              Container(
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.payment_outlined,
                            color: LightCodeColors().orangeA200,
                          ),
                          SizedBox(
                            width: 4.h,
                          ),
                          Text(
                            'Payment details',
                            style: CustomTextStyles.titleProductBlack,
                          ),
                        ],
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        children: [
                          SizedBox(
                            width: 8.h,
                          ),
                          Text(
                            'Total cost of goods: ',
                            style: CustomTextStyles.bodyMediumBluegray100
                                .copyWith(color: Colors.grey),
                          ),
                          Spacer(),
                          Text(
                            '\$${calculateTotal()}',
                            style:
                            TextStyle(color: LightCodeColors().orangeA200),
                          ),
                          SizedBox(
                            width: 16,
                          )
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 8.h,
                          ),
                          Text(
                            'Total shipping: ',
                            style: CustomTextStyles.bodyMediumBluegray100
                                .copyWith(color: Colors.grey),
                          ),
                          Spacer(),
                          Text(
                            '\$${_shipPrice}',
                            style:
                            TextStyle(color: LightCodeColors().orangeA200),
                          ),
                          SizedBox(
                            width: 16,
                          )
                        ],
                      ),
                      SizedBox(
                        height: 8.h,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 16.h,
                          ),
                          Text(
                            'Total payment: ',
                            style: CustomTextStyles.titleProductBlack
                                .copyWith(fontSize: 14.h),
                          ),
                          Spacer(),
                          Text(
                            '\$${calculateTotal() + _shipPrice}',
                            style:
                            TextStyle(color: LightCodeColors().orangeA200),
                          ),
                          SizedBox(
                            width: 16,
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 32.h,
              ),
              Container(
                color: Colors.white,
                child: Padding(
                    padding: EdgeInsets.all(8.h),
                    child: Center(
                        child: CustomElevatedButton(
                          text: 'Buy now',
                          onPressed: () async {
                            OrdersModel order = OrdersModel(
                              orderId: '',
                              userId: userId,
                              productItems: listSelect,
                              totalPrice: calculateTotal() + _shipPrice,
                              status: 'Pending',
                              createdAt: DateTime.now(),
                            );

                            if (_paymentMethod == 'COD') {
                              // If payment method is COD, keep the original logic
                              await ordersService.createOrder(order);
                              await cartService.deleteSelectedProducts(userId, listSelect);

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AfterOrder(),
                                ),
                              );
                            } else if (_paymentMethod == 'Online Payment') {
                              try {
                                // If payment method is Online Payment, call Stripe service
                                bool paymentSuccessful = await StripeService.instance.makePayment(
                                  amount: calculateTotal() + _shipPrice,
                                );

                                if (paymentSuccessful) {
                                  await ordersService.createOrder(order);
                                  await cartService.deleteSelectedProducts(userId, listSelect);

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AfterOrder(),
                                    ),
                                  );
                                } else {
                                  // Handle payment failure
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Payment failed, please try again.')),
                                  );
                                }
                              } catch (e) {
                                // Handle payment failure
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Payment failed, please try again.')),
                                );
                              }
                            }
                          },
                        )
                    )
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryOption(String title, double price, String description) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedDeliveryOption = title;
          _shipPrice = price;
        });
      },
      child: Card(
        color: _selectedDeliveryOption == title ? Colors.orange.shade100 : null,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(child: Text(title)),
              Text('${price.toString()} \$'),
              SizedBox(width: 8.0),
              Text(description),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethod() {
    return DropdownButtonFormField<String>(
      value: _paymentMethod,
      decoration: const InputDecoration(
        labelText: 'Payment Method',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      ),
      items: const [
        DropdownMenuItem(
          value: 'COD',
          child: Text('COD (Cash On Delivery)'),
        ),
        DropdownMenuItem(
          value: 'Online Payment',
          child: Text('Online Payment'),
        ),
      ],
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            _paymentMethod = newValue;
          });
        }
      },
    );
  }
}