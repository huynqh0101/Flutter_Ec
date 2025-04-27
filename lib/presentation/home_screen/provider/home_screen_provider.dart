import 'package:flutter/cupertino.dart';
import 'package:untitled/core/app_export.dart';
import '../../../model/product.dart';
import '../models/banner_list_item_model.dart';
import '../models/category_list_item_model.dart';
import '../models/home_screen_model.dart';

class HomeScreenProvider extends ChangeNotifier {
  TextEditingController searchController = TextEditingController();

  HomeScreenModel homeScreenModel = HomeScreenModel();

  int sliderIndex = 0;


  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

  void changeSliderIndex(int value) {
    sliderIndex = value;
    notifyListeners();
  }
}
