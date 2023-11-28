import '../../models/product/product.dart';

abstract class BaseRepository {
  Future<List<Product>> getCartList();
}
