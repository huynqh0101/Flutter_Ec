import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:untitled/model/product.dart';
import 'package:untitled/presentation/home_screen/home_screen.dart';
import 'package:untitled/presentation/home_screen/models/home_screen_model.dart';
import 'package:untitled/services/product_service.dart';
import 'package:untitled/widgets/custom_elevated_button.dart';

class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imgLinkController = TextEditingController();
  String? _selectedCategory;
  List<String> categories = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    categories = HomeScreenModel().categoryList.map((e) => e.name).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Product"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _productNameController,
                  decoration: InputDecoration(labelText: 'Product Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the product name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the product price';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _imgLinkController,
                  decoration: InputDecoration(labelText: 'Image Link'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the image link';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  },
                  items:
                      categories.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  decoration: InputDecoration(labelText: 'Category'),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                CustomElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      // Handle form submission
                      _submitProduct();
                    }
                  },
                  text: 'Add Product',

                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Handle the form submission and add the product
  void _submitProduct() {
    String productName = _productNameController.text;
    double price = double.parse(_priceController.text);
    String description = _descriptionController.text;
    String imgLink = _imgLinkController.text;
    String category = _selectedCategory ?? 'Electronics'; // Default category

    Product product = Product(
      product_id: '',
      product_name: productName,
      brand: '',
      about_product: description,
      actual_price: price,
      discounted_price: 0,
      rating: 0,
      rating_count: 0,
      discount_percentage: 0,
      img_link: imgLink,
      category: category,
      related_product: [],
    );

    ProductService().addProduct(product);

    Navigator.pop(context);
  }
}
