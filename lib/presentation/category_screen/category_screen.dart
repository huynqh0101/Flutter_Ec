import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/core/app_export.dart';
import 'package:untitled/presentation/home_screen/models/category_list_item_model.dart';

import '../../model/product.dart';
import '../detail_screen/detail_screen.dart';
import '../../services/product_service.dart';
import '../../theme/theme_helper.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_text_form_field.dart';
import '../../widgets/product_card.dart';
import '../home_screen/provider/home_screen_provider.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key, required this.category});

  final CategoryListItemModel category;

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late Future<List<Product>> productByCategoryList;

  @override
  void initState() {
    super.initState();
    productByCategoryList = ProductService().fetchProductsByCategory(widget.category.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
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
        ),
      ),
      body: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(top: 126.h),
            width: double.maxFinite,
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.h),
            decoration: BoxDecoration(
              color: appTheme.blueGray100.withOpacity(0.38),
            ),
            child: _buildProductGrid(context),
          ),
        ),
      ),
    );
  }

  /// Method for building the search section
  Widget _buildSearchSection(BuildContext context) {
    return Expanded(
      child: Selector<HomeScreenProvider, TextEditingController?>(
        selector: (context, provider) => provider.searchController,
        builder: (context, searchController, child) {
          return CustomTextFormField(
            hintText: widget.category.name,
            contentPadding:
            EdgeInsets.symmetric(horizontal: 12.h, vertical: 6.h),
            controller: searchController,
          );
        },
      ),
    );
  }

  /// Method for building the recommended product grid
  Widget _buildProductGrid(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: productByCategoryList,
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
            padding: EdgeInsets.zero,
            itemCount: relatedProducts.length,
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
