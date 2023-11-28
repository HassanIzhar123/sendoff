import '../../models/product/product.dart';

abstract class BaseRepository {
  Future<List<Product>> getProductsForCategory(String categoryID);
}
