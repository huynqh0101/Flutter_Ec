import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:untitled/core/app_export.dart';
import 'package:untitled/model/user.dart';
import 'package:untitled/presentation/orders_screen/my_order_screen.dart';
import 'package:untitled/services/shop_service/shop_service.dart';
import 'package:untitled/services/user_service.dart';
import 'package:untitled/widgets/custom_elevated_button.dart';
import 'package:untitled/presentation/welcome_onboarding_screen/welcome_onboarding_screen.dart';
import '../../model/shop_model.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../orders_screen/edit_info.dart';
import '../shop_screen/store_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}
//aa
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
      print(' userId $userId');
      final profile = await profileService.getUserProfile(userId);
      setState(() {
        userProfile = profile!;
      });
    } catch (e) {
      print('Error fetching user profile: $e');
    }
  }

  File? _image;

  Future<void> _requestPermission() async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      _pickAndUploadImage(); // Gọi hàm chọn ảnh khi có quyền
    } else {
      print("Không có quyền truy cập bộ nhớ!");
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      // Tạo đường dẫn lưu trữ ảnh trên Firebase Storage
      String fileName =
          'avatars/${DateTime.now().millisecondsSinceEpoch}${userProfile.uid}.png';
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);

      // Upload ảnh lên Firebase Storage
      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;

      // Lấy URL ảnh đã upload
      String imageUrl = await taskSnapshot.ref.getDownloadURL();

      // Lưu URL ảnh vào Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc('${userProfile.uid}')
          .update({
        'avatar_link': imageUrl,
      });

      setState(() {
        userProfile.avatar_link = imageUrl;
        _image = imageFile;
      });

      print("Ảnh đã được upload và URL là: $imageUrl");
    } else {
      print('Không có ảnh nào được chọn');
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
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            // Header với thiết kế bo tròn phía dưới
            Container(
              padding: EdgeInsets.only(
                  top: 60, left: 20, right: 20, bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: LightCodeColors().deepPurpleA200
                        .withOpacity(0.2),
                    child: userProfile.name != null &&
                        userProfile.name!.isNotEmpty
                        ? Text(
                      userProfile.name![0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 32.h,
                        fontWeight: FontWeight.bold,
                        color: LightCodeColors().deepPurpleA200,
                      ),
                    )
                        : Icon(Icons.person, size: 32.h,
                        color: LightCodeColors().deepPurpleA200),
                    radius: 40.h,
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10),
                        Text(
                          userProfile.name == null ? 'Name' : '${userProfile
                              .name}',
                          style: CustomTextStyles.titleMediumDeeppurpleA200
                              .copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFA88A5E), Color(0xFFD4AF37)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFFA88A5E).withOpacity(0.3),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            'Gold Member',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.only(left: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditInfo(
                                      user: userProfile,
                                    ),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Edit Profile',
                                style: CustomTextStyles.bodyMediumPrimary
                                    .copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 12,
                                color: LightCodeColors().deepPurpleA200,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // My Order với hiệu ứng nổi
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyOrderScreen()),
                  );
                },
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(0xFFFFD59E),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFFFD59E).withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          color: LightCodeColors().deepPurpleA200,
                          size: 32,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'My Orders',
                        style: CustomTextStyles.titleProductBlack.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 16),

            // Grid Buttons với thiết kế đẹp hơn
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                childAspectRatio: 3.0,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildGridItem(Icons.card_giftcard, 'Member Rewards', () {
                    print('member rewards');
                  }),
                  _buildGridItem(Icons.favorite, 'Favourites', () {
                    print('favourites');
                  }),
                  _buildGridItem(Icons.card_membership, 'Voucher', () {
                    print('voucher');
                  }),
                  _buildGridItem(Icons.settings, 'Settings', () {
                    print('settings');
                  }),
                  _buildGridItem(Icons.help, 'Help Center', () {
                    print('help center');
                  }),
                  _buildGridItem(Icons.payment, 'Payment Methods', () {
                    print('payment methods');
                  }),
                ],
              ),
            ),

            SizedBox(height: 24),

            // View Store Button
            if (userProfile.isSeller == true)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: CustomElevatedButton(
                  text: 'View Store',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StoreScreen(user: userProfile),
                      ),
                    );
                  },
                  buttonStyle: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      Color(0xFFFF9800),
                    ),
                    padding: MaterialStateProperty.all(
                      EdgeInsets.symmetric(vertical: 14),
                    ),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    elevation: MaterialStateProperty.all(4),
                  ),
                  buttonTextStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

            SizedBox(height: userProfile.isSeller == true ? 60 : 100),

            // Sign Out Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFF7941D), Color(0xFFFF9800)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFF7941D).withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: TextButton(
                  onPressed: () async {
                    try {
                      await AuthService().signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WelcomeOnboardingScreen(),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
                  },
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all(
                      EdgeInsets.symmetric(vertical: 15),
                    ),
                    overlayColor: MaterialStateProperty.all(Colors.white24),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.logout_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Sign Out',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

// Phương thức helper để tạo các item trong grid
  Widget _buildGridItem(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFFFFD59E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: LightCodeColors().deepPurpleA200,
                size: 18,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: CustomTextStyles.titleProductBlack.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
