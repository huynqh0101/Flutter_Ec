import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled/core/app_export.dart';
import 'package:untitled/model/product.dart';
import 'package:untitled/model/reviews.dart';
import 'custom_rating_bar.dart';
import 'package:untitled/widgets/lib/model/reviews.dart';

class ProductCard extends StatelessWidget {
  ProductCard(this.product, {super.key});


  final Product product;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 175.h,
        decoration: BoxDecoration(
          color: appTheme.whiteA700,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            CustomImageView(
              imagePath: product.img_link,
              height: 148.h,
              width: double.maxFinite,
              fit: BoxFit.contain,
            ),
            const Spacer(),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.only(left: 8.h),
                child: Text(
                  product.product_name,
                  maxLines: 2, // Giới hạn 2 dòng
                  textAlign: TextAlign.center, // Căn giữa văn bản
                  overflow: TextOverflow.ellipsis, // Thêm dấu "..." nếu văn bản quá dài
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),

            Container(
              width: double.maxFinite,
              margin: EdgeInsets.symmetric(horizontal: 8.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '\$${((product.actual_price * 0.012) * 100).round() / 100}',
                        style: CustomTextStyles.labelLargePrimary
                            .copyWith(fontSize: 18),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.only(left: 2.h),
                          child: Text(
                            '\$${((product.actual_price * 0.7 * 0.012) * 100).round() / 100}',
                            style: CustomTextStyles.labelLargePrimary.copyWith(
                                decoration: TextDecoration.lineThrough,
                                decorationColor: appTheme.blueGray100,
                                color: appTheme.blueGray100,
                                fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${product.rating}',
                        style: TextStyle(fontSize: 10, color: appTheme.orangeA200),
                      ),
                      Padding(
                          padding: EdgeInsets.only(left: 2.h),
                          child: CustomRatingBar(
                            ignoreGestures: true,
                            initialRating: product.rating,
                            color: appTheme.orangeA200,
                          )
                      ),
                    ],
                  )
                ],
              ),
            ),
            SizedBox(height: 4.h),
          ],
        ));
  }
}