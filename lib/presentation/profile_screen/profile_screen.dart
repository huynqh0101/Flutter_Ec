import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:untitled/core/app_export.dart';
import 'package:untitled/model/user.dart';
import 'package:untitled/presentation/orders_screen/my_order_screen.dart';
import 'package:untitled/presentation/welcome_onboarding_screen/welcome_onboarding_screen.dart';
import 'package:untitled/services/user_service.dart';
import 'package:untitled/widgets/custom_elevated_button.dart';
import '../shop_screen/store_screen.dart';


import '../../widgets/custom_bottom_bar.dart';
import '../orders_screen/edit_info.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ProfileService profileService = ProfileService();
  String userId = AuthService().getCurrentUser() == null
      ? ''
      : AuthService().getCurrentUser()!.uid;

  // final userId = AuthService().getCurrentUser()!.uid;
  CustomUser userProfile = CustomUser();

  @override
  void initState() {
    super.initState();

    userId = AuthService().getCurrentUser() == null
        ? ''
        : AuthService().getCurrentUser()!.uid;
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final profile = await profileService.getUserProfile(userId);
      setState(() {
        userProfile = profile!;
      });
    } catch (e) {
      print('Error fetching user profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightCodeColors().deepPurpleA200,
      bottomNavigationBar: SizedBox(
          width: double.maxFinite,
          child: CustomBottomBar(
            selectedIndex: 2,
            onChanged: (BottomBarEnum type) {},
          )),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              padding:
              EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 14),
              color: Colors.white, // Màu nền header
              child: Row(
                children: [
                  CircleAvatar(
                    child: userProfile.name != null && userProfile.name!.isNotEmpty
                        ? Text(userProfile.name![0].toUpperCase())
                        : Icon(Icons.person), // Hiển thị icon mặc định khi name null
                    radius: 40.h,
                  ),
                  SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      Text(
                          userProfile.name == null
                              ? 'Name'
                              : '${userProfile.name}',
                          style: CustomTextStyles.titleMediumDeeppurpleA200
                              .copyWith(fontSize: 20)),
                      Container(
                        padding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Color(0xFFA88A5E),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Gold Member',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.only(left: 4),
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditInfo(
                                    user: userProfile,
                                  )));
                        },
                        child: Text(
                          'Edit Profile >',
                          style: CustomTextStyles.bodyMediumPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // My Order
            Padding(
              padding: EdgeInsets.all(12.0),
              child: GestureDetector(
                onTap: () {
                  print('my order');
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MyOrderScreen()));
                },
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Color(0xFFFFD59E),
                        child: Icon(Icons.shopping_bag_outlined,
                            color: LightCodeColors().deepPurpleA200, size: 32),
                      ),
                      SizedBox(height: 5),
                      Text('My Order',
                          style: CustomTextStyles.titleProductBlack),
                    ],
                  ),
                ),
              ),
            ),
            // Grid Buttons
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              childAspectRatio: 3.2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              padding: EdgeInsets.symmetric(horizontal: 12),
              children: [
                GestureDetector(
                    onTap: () {
                      print('member rewards');
                    },
                    child: GridItem(
                        icon: Icons.card_giftcard, title: 'Member Rewards')),
                GestureDetector(
                    onTap: () {
                      print('favourites');
                    },
                    child: GridItem(icon: Icons.favorite, title: 'Favourites')),
                GestureDetector(
                    onTap: () {
                      print('voucher');
                    },
                    child: GridItem(
                        icon: Icons.card_membership, title: 'Voucher')),
                GestureDetector(
                    onTap: () {
                      print('settings');
                    },
                    child: GridItem(icon: Icons.settings, title: 'Settings')),
                GestureDetector(
                    onTap: () {
                      print('help center');
                    },
                    child: GridItem(icon: Icons.help, title: 'Help Center')),
                GestureDetector(
                    onTap: () {
                      print('payment methods');
                    },
                    child: GridItem(
                        icon: Icons.payment, title: 'Payment Methods')),
              ],
            ),
            SizedBox(height: 15),
            if (userProfile.isSeller == true)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomElevatedButton(
                    text: 'View Store', onPressed: (){
                  // ShopService().createShop(ShopModel(id: userProfile.uid!, name: userProfile.name!));
                  Navigator.push(context, MaterialPageRoute(builder: (context) => StoreScreen(user: userProfile,)));
                }),
              ),
            // Upgrade Button
            SizedBox(height: 110),

            TextButton(
              onPressed: () async {
                try {
                  await AuthService().signOut();

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => WelcomeOnboardingScreen()),
                  );
                } catch (e) {
                  // Hiển thị thông báo lỗi
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              },
              child: Text(
                'Sign Out',
                style: CustomTextStyles.bodyMediumPrimary
                    .copyWith(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _viewStore() {}

  void _createStore() {}

// Widget _buildProfileField(
//     String label, String initialValue, Function(String) onChanged) {
//   return Padding(
//     padding: const EdgeInsets.symmetric(vertical: 8.0),
//     child: TextFormField(
//       initialValue: initialValue,
//       decoration: InputDecoration(
//         labelText: label,
//         border: OutlineInputBorder(),
//       ),
//       onChanged: onChanged,
//     ),
//   );
// }

// Widget _buildRoleField() {
//   return Padding(
//     padding: const EdgeInsets.symmetric(vertical: 8.0),
//     child: TextFormField(
//       initialValue: userProfile.isSeller! ? 'Seller' : 'Buyer',
//       readOnly: true,
//       decoration: InputDecoration(
//         labelText: 'Role',
//         border: OutlineInputBorder(),
//       ),
//     ),
//   );
// }
}

class GridItem extends StatelessWidget {
  final IconData icon;
  final String title;

  const GridItem({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Color(0xFFFFD59E),
            radius: 18,
            child:
            Icon(icon, color: LightCodeColors().deepPurpleA200, size: 20),
          ),
          SizedBox(width: 4),
          Text(
            title,
            style: CustomTextStyles.titleProductBlack.copyWith(fontSize: 14),
          ),
        ],
      ),
    );
  }
}