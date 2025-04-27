import 'package:flutter/material.dart';
import '../core/app_export.dart';

class AppDecoration {
  static BoxDecoration get baseWhite => BoxDecoration(
    color: theme.colorScheme.onPrimary,
    boxShadow: [
      BoxShadow(
        color: appTheme.black900.withOpacity(0.1),
        spreadRadius: 2.h,
        blurRadius: 2.h,
        offset: Offset(0, 10)
      )
    ],
  );

  static BoxDecoration get gray100 => BoxDecoration(
    color: theme.colorScheme.onPrimary,
    border: Border.all(
      color: appTheme.gray200,
      width: 0.5.h,
    )
  );

}