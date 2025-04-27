import 'package:flutter/material.dart';
import 'package:untitled/model/product.dart';

class ProductItem extends StatelessWidget {
  final Product product;
  final Function(String) onDelete;  // Thêm callback để xóa sản phẩm

  const ProductItem({super.key, required this.product, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          // Xử lý khi nhấn vào sản phẩm
        },
        child: Row(
          children: [
            // Hình ảnh sản phẩm
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                product.img_link,
                height: 80,
                width: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.broken_image, size: 80);
                },
              ),
            ),
            const SizedBox(width: 16),
            // Thông tin sản phẩm
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.product_name,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "\$${product.actual_price.toStringAsFixed(2)}",
                    style: TextStyle(color: Colors.green, fontSize: 14),
                  ),
                ],
              ),
            ),
            // Nút xóa
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                onDelete(product.product_id);  // Gọi callback khi nhấn nút xóa
              },
            ),
          ],
        ),
      ),
    );
  }
}
