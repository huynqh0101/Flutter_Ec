import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:untitled/core/app_export.dart';
import '../../model/product.dart';
import '../../services/product_service.dart';
import '../../theme/theme_helper.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_text_form_field.dart';
import '../../widgets/product_card.dart';
import '../detail_screen/detail_screen.dart';
import '../home_screen/models/category_list_item_model.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key, required this.category});

  final CategoryListItemModel category;

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<Product> _products = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _limit = 10;
  DocumentSnapshot? _lastDocument;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchProducts() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newProducts = await ProductService().fetchProductsByCategory(
        categoryId: widget.category.id,
        limit: _limit,
        lastDocument: _lastDocument,
      );

      setState(() {
        _products.addAll(newProducts);
        if (newProducts.isNotEmpty) {
          _lastDocument = newProducts.last.documentSnapshot;
        }
        if (newProducts.length < _limit) {
          _hasMore = false;
        }
      });
    } catch (e) {
      // Xử lý lỗi tải dữ liệu (nếu cần)
      debugPrint('Error fetching products: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _fetchProducts();
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      bottomNavigationBar: CustomBottomBar(
        selectedIndex: 0,
        onChanged: (BottomBarEnum type) {},
      ),
      body: Column(
        children: [
          SizedBox(height: 126.h), // Thay thế cho margin của body
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.h),
              decoration: BoxDecoration(
                color: appTheme.blueGray100.withOpacity(0.38),
              ),
              child: _buildProductGrid(),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
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
          child: Container(color: appTheme.deepPurpleA200),
        ),
        title: CustomTextFormField(
          hintText: widget.category.name,
          contentPadding:
          EdgeInsets.symmetric(horizontal: 12.h, vertical: 6.h),
        ),
      ),
    );
  }

  Widget _buildProductGrid() {
    return _products.isEmpty && !_isLoading
        ? Center(child: Text('No related products found.'))
        : Expanded(
      child: Column(
        children: [
          Expanded(
            child: GridView.builder(
              controller: _scrollController,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              padding: EdgeInsets.zero,
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
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
            ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          if (!_hasMore && !_isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('No more products to load'),
            ),
        ],
      ),
    );
  }

}