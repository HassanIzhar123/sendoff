import 'package:sendoff/models/category/category.dart';
import 'package:sendoff/models/product/product.dart';

class CategoryProduct {
  CategoryProduct(this.categoryOrProduct, this.category, this.product);

  CategoryOrProduct categoryOrProduct;

  @override
  String toString() {
    return 'CategoryProduct{categoryOrProduct: $categoryOrProduct, category: $category, product: $product}';
  }

  Category? category;
  Product? product;
}

enum CategoryOrProduct {
  category,
  product,
}
