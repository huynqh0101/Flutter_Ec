import 'package:flutter/material.dart';
import 'package:untitled/core/app_export.dart';
import 'package:untitled/model/product.dart';
import 'package:untitled/presentation/detail_screen/detail_screen.dart';
import 'package:untitled/services/product_service.dart';
import 'package:untitled/widgets/custom_bottom_bar.dart'; // Add this import
import 'dart:math';

class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<Product> products = [];
  List<Product> recommendedProducts = [];
  bool isLoading = true;
  String selectedCategory = "All";
  List<String> categories = ["All", "Recommended"];
  int _selectedIndex = 3; // Default to Menu tab (index 3)
  
  final ProductService _productService = ProductService(); // Sử dụng ProductService

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      // Hiển thị loading
      setState(() {
        isLoading = true;
      });
      
      // Tải tất cả sản phẩm
      final loadedProducts = await _productService.fetchAllProducts();
      
      // Tải sản phẩm đề xuất - sử dụng phương thức mới
      // Giả sử user_1 là người dùng hiện tại, bạn có thể thay thế bằng ID người dùng thực
      final recommended = await _productService.fetchLocalRecommendedProducts('user_1');
      
      // Trích xuất tất cả danh mục
      Set<String> categorySet = {"All", "Recommended"};
      for (var product in loadedProducts) {
        if (product.category.isNotEmpty) {
          if (product.category is String) {
            categorySet.add(product.category);
          } else if (product.category is List && product.category.isNotEmpty) {
            categorySet.add(product.category[0]);
          }
        }
      }

      setState(() {
        products = loadedProducts;
        recommendedProducts = recommended;
        categories = categorySet.toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error loading products: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Products"),
        backgroundColor: appTheme.deepPurpleA200,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Categories horizontal list
          Container(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: ChoiceChip(
                    label: Text(categories[index]),
                    selected: selectedCategory == categories[index],
                    onSelected: (selected) {
                      setState(() {
                        selectedCategory = categories[index];
                      });
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: appTheme.deepPurpleA200.withOpacity(0.7),
                    labelStyle: TextStyle(
                      color: selectedCategory == categories[index]
                          ? Colors.white
                          : Colors.black,
                    ),
                    // Thêm icon cho Recommended
                    avatar: categories[index] == "Recommended"
                        ? Icon(
                      Icons.thumb_up,
                      size: 16,
                      color: selectedCategory == "Recommended" ? Colors.white : Colors.amber,
                    )
                        : null,
                  ),
                );
              },
            ),
          ),

          // Hiển thị tiêu đề khi chọn Recommended
          if (selectedCategory == "Recommended")
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                "Top Picks For You",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: appTheme.deepPurpleA200,
                ),
              ),
            ),

          // Products grid
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _getFilteredProducts().length,
              itemBuilder: (context, index) {
                Product product = _getFilteredProducts()[index];
                return _buildProductCard(product);
              },
            ),
          ),
        ],
      ),

      bottomNavigationBar: CustomBottomBar(
        selectedIndex: _selectedIndex,
        onChanged: (BottomBarEnum type) {
          // Navigation is handled inside CustomBottomBar
        },
        onSelectedIndexChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  //Trả về danh sách snar phẩm đề xuất
  List<Product> _getFilteredProducts() {
    if (selectedCategory == "All") {
      return products;
    } else if (selectedCategory == "Recommended") {
      return recommendedProducts; // Trả về danh sách sản phẩm đề xuất
    }
    return products.where((product) => product.category == selectedCategory).toList();
  }

  Widget _buildProductCard(Product product) {
    // Thêm badge cho sản phẩm đề xuất
    bool isRecommended = recommendedProducts.any((p) => p.product_id == product.product_id) &&
        selectedCategory != "Recommended"; // Chỉ hiển thị badge khi không ở tab Recommended

    return GestureDetector(
      onTap: () {
        // Navigate to the product detail screen when card is tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product image
                Expanded(
                  flex: 3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                    child: Image.network(
                      product.img_link,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: Icon(Icons.image_not_supported, size: 50),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(child: CircularProgressIndicator());
                      },
                    ),
                  ),
                ),

                // Product details
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Product name
                        Text(
                          product.product_name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),

                        // Pricing and rating
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "₹${product.discounted_price.toStringAsFixed(0)}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                                if (product.actual_price > product.discounted_price)
                                  Text(
                                    "₹${product.actual_price.toStringAsFixed(0)}",
                                    style: TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 14),
                                Text(
                                  product.rating.toStringAsFixed(1),
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Badge cho sản phẩm đề xuất
            if (isRecommended)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.thumb_up, color: Colors.white, size: 12),
                      SizedBox(width: 2),
                      Text(
                        "Top",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );



  }
}
