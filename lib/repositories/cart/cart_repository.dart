import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/product/product.dart';
import 'base_repository.dart';

class CartRepository extends BaseRepository {

  @override
  Future<List<Product>> getCartList() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? serializedList = prefs.getStringList('cartList');
    if (serializedList == null) {
      return [];
    }
    final List<Product> list = serializedList.map((jsonString) => Product.fromJson(json.decode(jsonString))).toList();
    return list;
  }
}
