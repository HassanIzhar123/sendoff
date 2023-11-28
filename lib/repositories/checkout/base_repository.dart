import '../../models/PushOrder/Order.dart' as order_number;
import '../../models/cart/push_order_model.dart';
import '../../models/product/product.dart';

abstract class BaseRepository {
  Future<PushOrderModel?> pushOrder(String customerId, order_number.Order order);

  Future<List<Product>> getCartList();
}
