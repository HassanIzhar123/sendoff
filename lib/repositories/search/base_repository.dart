import '../../models/PushOrder/Order.dart' as order_number;
import '../../models/chats/admin.dart';

abstract class BaseRepository {
  Future<Admin?> getAdminData();
  Future<List<order_number.Order>> getRunningOrderCount(String? customerId);
}