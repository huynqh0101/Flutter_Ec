import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/core/app_export.dart';
import 'package:untitled/model/Cart/cart_item.dart';
import 'package:untitled/model/product.dart';
import 'package:untitled/presentation/sign_in_screen/sign_in_screen.dart';
import 'package:untitled/services/cart_service.dart';
import 'package:untitled/services/product_service.dart';
import 'package:untitled/theme/custom_text_style.dart';
import 'package:untitled/widgets/custom_elevated_button.dart';
import 'package:untitled/widgets/custom_rating_bar.dart';
import 'package:untitled/widgets/product_card.dart';
import '../../model/reviews.dart';
import '../../model/user.dart';
import '../../services/my_order_service.dart';
import '../../services/user_service.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_text_form_field.dart';
import '../home_screen/provider/home_screen_provider.dart';
import '../home_screen/search_screen.dart';
import 'package:intl/intl.dart';

import '../orders_screen/order_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool isExpandedDetails = false;
  bool isExpandedReviews = false;

  late Future<List<Review>> reviewsFuture;
  late Future<List<Product>> relatedProductFuture;
  late Future<List<Product>> firestoreProductList;
  String? userName;
  late CartService cartService;
  var userId;

  @override
  void initState() {
    super.initState();
    reviewsFuture = widget.product.fetchAllReviews(widget.product.product_id);
    relatedProductFuture = widget.product.fetchRelatedProducts(widget.product.product_id);
    firestoreProductList = ProductService().fetchAllProducts();
    userId = AuthService().getCurrentUser()?.uid;
    cartService = CartService();

    // Move async operation to separate method
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    userName = await getUsernameFromUserId(userId);
    print("username ${userName}");
    if (mounted) {
      setState(() {});
    }
  }


  Future<String?> getUsernameFromUserId(String userId) async {
    try {
      // Truy vấn Firestore để lấy dữ liệu người dùng từ userId
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')  // Thay đổi tên collection nếu cần
          .doc(userId)
          .get();

      // Kiểm tra nếu document tồn tại
      if (userDoc.exists) {
        // Lấy thông tin 'username' từ document
        String username = userDoc.get('name');  // Thay 'username' bằng trường trong Firestore của bạn
        return username;
      } else {
        print("User not found");
        return null;
      }
    } catch (e) {
      print("Error getting username: $e");
      return null;
    }
  }

  int quantity = 1;

  void increment() {
    setState(() {
      quantity++;
    });
  }

  void decrement() {
    setState(() {
      if (quantity > 1) {
        quantity--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: AppBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          toolbarHeight: 110.0,
          flexibleSpace: ClipRRect(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(12.h),
              bottomRight: Radius.circular(12.h),
            ),
            child: Container(
              color: appTheme.deepPurpleA200,
            ),
          ),
          title: _buildSearchSection(context),
        ),
      ),
      bottomNavigationBar: SizedBox(
          width: double.maxFinite,
          child: CustomBottomBar(
            selectedIndex: 0,
            onChanged: (BottomBarEnum type) {},
          )),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            AspectRatio(
                aspectRatio: 1.2,
                child: CustomImageView(
                  imagePath: widget.product.img_link,
                  fit: BoxFit.contain,
                )),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Price and Discount
                Container(
                  color: LightCodeColors().deepPurpleA200,
                  height: 60.h,
                  child: Row(
                    children: [
                      SizedBox(width: 18.h,),
                      Text('\$ ${widget.product.discounted_price}',
                          style: CustomTextStyles.labelLargePrimary.copyWith(
                              fontSize: 20.h,
                              color: LightCodeColors().orangeA200)),
                      const SizedBox(width: 8),
                      Text(
                        '\$ ${widget.product.actual_price}',
                        style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.white,
                            fontSize: 20.h
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        margin: EdgeInsets.only(right: 16.h),
                        decoration: BoxDecoration(
                          color: LightCodeColors().orangeA200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'SALE ${widget.product.discount_percentage} \%',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // Product Title and Rating
                  Text('${widget.product.product_name}]',
                      style: CustomTextStyles.titleProductBlack),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${widget.product.rating}',
                        style:
                        TextStyle(fontSize: 16, color: appTheme.orangeA200),
                      ),
                      CustomRatingBar(
                        ignoreGestures: true,
                        initialRating: widget.product.rating,
                        color: appTheme.orangeA200,
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'In Stock',
                        style: CustomTextStyles.bodyMediumDeeppurpleA200_1
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        height: 44.h,
                        decoration: BoxDecoration(
                            color: LightCodeColors().gray200,
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(children: [
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            'Quantity',
                            style: CustomTextStyles.bodySmallBlack900.copyWith(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Spacer(),
                          Center(
                            child: Container(
                              height: 28.h,
                              decoration: BoxDecoration(
                                  color: LightCodeColors().gray5001,
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(5)),
                              child: Row(
                                // mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,

                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  IconButton(
                                      onPressed: decrement,
                                      icon: Icon(Icons.remove)),
                                  Text('$quantity'),
                                  IconButton(
                                      onPressed: increment,
                                      icon: Icon(Icons.add))
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          )
                        ]),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            cartService.addToCart(widget.product, userId, quantity);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: LightCodeColors().deepPurpleA200,
                            minimumSize: Size(3.h, 60.h),
                          ),
                          child: Text(
                            'Add to cart',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: CustomElevatedButton(
                          onPressed: () {
                            // Check if the user is logged in
                            if (userId == null || userId.isEmpty) {
                              // User is not logged in, navigate to the login screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => SignInScreen()),
                              );
                            } else {
                              // User is logged in, proceed with the buy now functionality
                              // Navigate to the purchase page (replace this with your actual purchase page)
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => OrderScreen(items: [CartItem(productId: widget.product.product_id, productName: widget.product.product_name, imageUrl: widget.product.img_link, price: widget.product.discounted_price)],)),
                              );
                            }
                          },
                          text: 'Buy now',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Product Details
                  InkWell(
                    onTap: () {
                      setState(() {
                        isExpandedDetails = !isExpandedDetails;
                      });
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Product Details',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(
                              isExpandedDetails
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.product.about_product,
                          maxLines: isExpandedDetails ? null : 3,
                          overflow:
                          isExpandedDetails ? null : TextOverflow.ellipsis,
                        ),
                        if (!isExpandedDetails)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                isExpandedDetails = true;
                              });
                            },
                            child: Text(
                              'More',
                              style: CustomTextStyles.titleSmallPrimary,
                            ),
                          ),
                      ],
                    ),
                  ),

                  const Text(
                    'Write a Review',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  // Customer Reviews
                  Container(
                    padding: EdgeInsets.all(2),
                    child: FutureBuilder<Widget>(
                      future: _buildReviewForm(context), // Call your async method here
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator()); // Show loading while waiting for result
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}')); // Show error if any
                        } else if (snapshot.hasData) {
                          return snapshot.data!; // Return the Widget when Future is completed
                        } else {
                          return Center(child: Text('No data available'));
                        }
                      },
                    ),
                  ),


                  Container(
                      padding: EdgeInsets.all(2), child: Customer_review()),


                  // Related Products
                  const Text(
                    'Related Products',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildRelatedProductItem(widget.product)
                  // _buildReviewsSection(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection(BuildContext context) {
    return Expanded(
      child: Selector<HomeScreenProvider, TextEditingController?>(
        selector: (context, provider) => provider.searchController,
        builder: (context, searchController, child) {
          return CustomTextFormField(
            hintText: "Search",
            contentPadding:
            EdgeInsets.symmetric(horizontal: 12.h, vertical: 6.h),
            controller: searchController,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SearchScreen()));
            },
          );
        },
      ),
    );
  }

  Column Customer_review() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Customer Reviews',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  isExpandedReviews = !isExpandedReviews;
                });
              },
              child: Text(
                isExpandedReviews ? 'Show Less' : 'See All',
                style: TextStyle(color: Color(0xFFFA993A)),
              ),
            ),
          ],
        ),
        FutureBuilder<List<Review>>(
          future: reviewsFuture, // Tham chiếu đến Future trả về danh sách reviews
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(); // Hiển thị loading khi chờ dữ liệu
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}'); // Hiển thị lỗi nếu có
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('No reviews available'); // Không có review
            } else {
              final reviews = snapshot.data!;
              // Nếu không đủ 3 review, hiển thị tất cả review có trong danh sách
              final reviewsToDisplay = isExpandedReviews || reviews.length <= 3
                  ? reviews
                  : reviews.take(3).toList(); // Lấy tối đa 3 review

              return Column(
                children: List.generate(
                  reviewsToDisplay.length, // Sử dụng số lượng review thực tế cần hiển thị
                      (index) {
                    final review = reviewsToDisplay[index];
                    return _buildReviewItem(review);
                  },
                ),
              );
            }
          },
        )

      ],
    );
  }

  Widget _buildReviewItem(Review review) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CustomRatingBar(
                    ignoreGestures: true,
                    initialRating: review.rating,
                    color: appTheme.orangeA200,
                    itemSize: 20.h,
                  ),
                  SizedBox(width: 8),
                  Text(
                    review.rating.toString(),  // Display the rating number next to the RatingBar
                    style: CustomTextStyles.titleProductBlack.copyWith(
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                      color: appTheme.orangeA200,
                    ),
                  ),
                ],
              ),
              Text(
                DateFormat('dd-MM-yyyy').format(review.review_time),
                style: CustomTextStyles.titleProductBlack.copyWith(fontWeight: FontWeight.normal),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                child: Text(review.review_name[0].toUpperCase()),
              ),
              SizedBox(width: 12),
              Text(
                review.review_name,
                style: CustomTextStyles.titleProductBlack.copyWith(fontWeight: FontWeight.normal),
              ),
            ],
          ),
          SizedBox(height: 9),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                review.review_title,
                style: CustomTextStyles.titleProductBlack,
              ),
              SizedBox(height: 4),
              // Use ExpansionTile to toggle the full content visibility
              ExpansionTile(
                title: Text(
                  review.review_content,
                  style: CustomTextStyles.bodyMediumGray200.copyWith(color: Colors.black),
                  maxLines: 3,  // Limit the review content to 3 lines
                  overflow: TextOverflow.ellipsis,  // Use ellipsis for overflow text
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      review.review_content,
                      style: CustomTextStyles.bodyMediumGray200.copyWith(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }



  Widget _buildRelatedProductItem(Product product) {
    return FutureBuilder<List<Product>>(
      future: relatedProductFuture, // Tham chiếu đến hàm lấy thông tin sản phẩm từ IDs
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No related products found.'));
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
            itemCount: relatedProducts.length,
            itemBuilder: (context, index) {
              final relatedProduct = relatedProducts[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProductDetailScreen(product: relatedProduct),
                    ),
                  );
                },
                child: ProductCard(relatedProduct),
              );
            },
          );
        }
      },
    );
  }

  Future<Widget> _buildReviewForm(BuildContext context) async {
    final TextEditingController reviewTitleController = TextEditingController();
    final TextEditingController reviewContentController = TextEditingController();
    double rating = 0.0;

    if (userId == null) {
      return Center(
        child: Text(
          'Please log in to write a review.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    if (!(await MyOrderService().hasUserPurchasedProduct(userId, widget.product.product_id))) {
      return Center(
        child: Text(
          'Please buy product to write a review.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rating Section
          Row(
            children: [
              Text(
                'Rating: ',
                style: CustomTextStyles.labelLargePrimary.copyWith(fontSize: 20),
              ),
              CustomRatingBar(
                itemSize: 20,
                onRatingUpdate: (newRating) {
                  rating = newRating;
                },
                color: appTheme.orangeA200,
              ),
              Spacer(),
            ],
          ),
          const SizedBox(height: 8),

          // Title Input
          TextField(
            controller: reviewTitleController,
            decoration: const InputDecoration(
              labelText: 'Review Title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),

          // Content Input
          TextField(
            controller: reviewContentController,
            decoration: const InputDecoration(
              labelText: 'Review Content',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 8),

          // Submit Button
          CustomElevatedButton(
            text: 'Submit Review',
            onPressed: () {
              if (reviewTitleController.text.isNotEmpty &&
                  reviewContentController.text.isNotEmpty &&
                  rating > 0) {
                // Assuming you have a function to handle review submission
                _submitReview(
                  reviewTitleController.text,
                  reviewContentController.text,
                  rating,
                );
                // Clear the input fields after submission
                reviewTitleController.clear();
                reviewContentController.clear();
              } else {
                // Show a message if validation fails
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please fill all fields and provide a rating.'),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }


// This function would handle the review submission, like storing the review in Firestore or a backend
  void _submitReview(String title, String content, double rating) async {
    // Tạo review mới
    Review newReview = Review(
      review_name: userName!, // Thay bằng tên người dùng thực tế
      review_title: title,
      review_content: content,
      review_time: DateTime.now(),
      rating: rating,
      user_id: userId,
      product_id: widget.product.product_id,
    );

    try {
      // Thêm review vào Firestore
      FirebaseFirestore.instance.collection('new_reviews').add({
        'review_name': newReview.review_name,
        'review_title': newReview.review_title,
        'review_content': newReview.review_content,
        'rating': newReview.rating,
        'user_id': newReview.user_id,
        'product_id': newReview.product_id,
        'review_time': newReview.review_time.toIso8601String(),
      }).then((value) {
        print("Review added successfully");
      }).catchError((error) {
        print("Failed to add review: $error");
      });
    } catch (e) {
      print("Error adding review: $e");
    }

    try {
      // Chuyển đổi review_time thành Unix timestamp (milliseconds since epoch)
      int reviewTimeInMilliseconds = newReview.review_time.millisecondsSinceEpoch;

      // Thêm review vào Firestore
      FirebaseFirestore.instance.collection('reviews').add({
        'user_name': newReview.review_name,
        'summary': newReview.review_title,
        'review_text': newReview.review_content,
        'rating': newReview.rating,
        'user_amazon_id': newReview.user_id,
        'item_amazon_id': newReview.product_id,
        'review_time': reviewTimeInMilliseconds,  // Lưu dưới dạng milliseconds
      }).then((value) {
        print("Review added successfully");
      }).catchError((error) {
        print("Failed to add review: $error");
      });
    } catch (e) {
      print("Error adding review: $e");
    }


  }



}