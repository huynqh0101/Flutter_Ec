import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/presentation/detail_screen/detail_screen.dart';
import 'package:untitled/presentation/home_screen/models/banner_list_item_model.dart';
import 'package:untitled/presentation/home_screen/models/home_screen_model.dart';
import 'package:untitled/presentation/home_screen/search_screen.dart';
import '../../core/app_export.dart';
import '../../model/product.dart';
import '../../widgets/custom_text_form_field.dart';
import '../category_screen/category_screen.dart';
import 'widgets/banner_list_item_widget.dart';
import 'widgets/product_slider_list_item_widget.dart';
import 'widgets/category_list_item_widget.dart';
import 'package:untitled/widgets/product_card.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'provider/home_screen_provider.dart';
import '../../widgets/custom_bottom_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();

  static Widget builder(BuildContext context) {
    return HomeScreen();
    // return ChangeNotifierProvider(
    //   create: (context) => HomeScreenProvider(),
    //   child: const HomeScreen(),
    // );
  }
}

class HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    final provider = context.read<HomeScreenProvider>();
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
          )),
      body: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: SizedBox(
              width: double.maxFinite,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 150.h),
                  _buildBannerSection(context),
                  SizedBox(height: 24.h),
                  Container(
                    width: double.maxFinite,
                    padding: EdgeInsets.only(top: 16.h, bottom: 36.h),
                    decoration: BoxDecoration(
                      color: appTheme.deepPurpleA200,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTrendingSection(context),
                        SizedBox(height: 16.h),
                        _buildSaleSection(context),
                      ],
                    ),
                  ),
                  SizedBox(height: 32.h),
                  _buildCategorySliderSection(context),
                  // SizedBox(height: 22.h),
                  Padding(
                    padding: EdgeInsets.only(left: 16.h),
                    child: Text(
                      "Recommend For You".toUpperCase(),
                      style: CustomTextStyles.labelLargePrimary
                          .copyWith(fontSize: 14.h),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    width: double.maxFinite,
                    padding:
                        EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.h),
                    decoration: BoxDecoration(
                      color: appTheme.blueGray100.withOpacity(0.38),
                    ),
                    child: _buildRecommendedProductGrid(context),
                  )
                ],
              ),
            ),
          )),
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

  Widget _buildBannerSection(BuildContext context) {
    return Consumer<HomeScreenProvider>(
      builder: (context, provider, child) {
        return CarouselSlider.builder(
          itemCount: 2,
          itemBuilder: (context, index, realIndex) {
            BannerListItemModel model =
                provider.homeScreenModel.bannerList[index];
            return BannerListItemWidget(model);
          },
          options: CarouselOptions(
            height: 140.h,
            // Adjust height as needed
            viewportFraction: 0.8,
            // Shows partial next and previous items
            enlargeCenterPage: false,
            // Makes the current item larger
            autoPlay: true,
            // Auto-scrolling
            autoPlayInterval: const Duration(seconds: 3),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enableInfiniteScroll: true,
            padEnds: true,
            scrollDirection: Axis.horizontal,
          ),
        );
      },
    );
  }

  Widget _buildTrendingSection(BuildContext context) {
    return Container(
      width: double.maxFinite,
      margin: EdgeInsets.only(left: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "trending".toUpperCase(),
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
          SizedBox(height: 6.h),
          Container(
            width: double.maxFinite,
            child: FutureBuilder<List<Product>>(
              future: HomeScreenModel().getTrendingProductList(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                      child: Text('No products available')); // Không có dữ liệu
                }
                final items = snapshot.data!;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Wrap(
                    direction: Axis.horizontal,
                    spacing: 6.h,
                    children: List.generate(items.length, (index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductDetailScreen(product: items[index]),
                            ),
                          );
                        },
                        child: ProductSliderListItemWidget(items[index]),
                      );
                    }),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaleSection(BuildContext context) {
    return Container(
      width: double.maxFinite,
      margin: EdgeInsets.only(left: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "flash sale".toUpperCase(),
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
          SizedBox(height: 6.h),
          Container(
            width: double.maxFinite,
            child: FutureBuilder<List<Product>>(
              future: HomeScreenModel().getSaleProductList(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                      child: Text('No products available')); // Không có dữ liệu
                }
                final items = snapshot.data!;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Wrap(
                    direction: Axis.horizontal,
                    spacing: 6.h,
                    children: List.generate(items.length, (index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductDetailScreen(product: items[index]),
                            ),
                          );
                        },
                        child: ProductSliderListItemWidget(items[index]),
                      );
                    }),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySliderSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 4.h),
      child: Consumer<HomeScreenProvider>(
        builder: (context, provider, _) {
          final categoryList = provider.homeScreenModel.categoryList;
          return CarouselSlider.builder(
            options: CarouselOptions(
              height: 110.h,
              // Responsive height
              initialPage: 0,
              autoPlay: true,
              viewportFraction: 0.2,
              scrollDirection: Axis.horizontal,
              onPageChanged: (index, _) => provider.changeSliderIndex(index),
            ),
            itemCount: categoryList.length,
            itemBuilder: (context, index, _) {
              return CategoryListItemWidget(
                categoryListItemObj: categoryList[index],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CategoryScreen(category: categoryList[index]),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildRecommendedProductGrid(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: HomeScreenModel().recommendedProductList(),
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
            itemCount: 50,
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
