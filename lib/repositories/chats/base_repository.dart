import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/PushOrder/Order.dart' as order_number;
import '../../models/cart/push_order_model.dart';
import '../../models/chats/admin.dart';
import '../../models/chats/chat.dart';

abstract class BaseRepository {
  Future<Stream<QuerySnapshot<Map<String, dynamic>>>> getChats(
      String customerId, int messagesPerPage, DocumentSnapshot? lastDocument);

  Future<PushOrderModel> sendMessage(String customerId, Chat chat);

  Future<Admin?> getAdminData();

  Future<List<order_number.Order>> getRunningOrderCount();
}
