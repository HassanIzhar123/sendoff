import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/PushOrder/OrderProduct.dart';
import '../../models/cart/push_order_model.dart';
import '../../models/chats/admin.dart';
import '../../models/chats/chat.dart';
import 'base_repository.dart';
import '../../models/PushOrder/Order.dart' as order_number;

class ChatsRepository extends BaseRepository {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  @override
  Future<Stream<QuerySnapshot<Map<String, dynamic>>>> getChats(
      String customerId, int messagesPerPage, DocumentSnapshot? lastDocument) async {
    if (lastDocument != null) {
      return FirebaseFirestore.instance
          .collection('chat-rooms')
          .doc(customerId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .startAfterDocument(lastDocument)
          .limit(messagesPerPage)
          .snapshots();
    } else {
      return FirebaseFirestore.instance
          .collection('chat-rooms')
          .doc(customerId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(messagesPerPage)
          .snapshots();
    }
  }

  @override
  Future<PushOrderModel> sendMessage(String customerId, Chat chat) async {
    try {
      final DocumentReference orderCollectionRef = _fireStore.collection('chat-rooms').doc(customerId);
      final CollectionReference orderDocumentRef = orderCollectionRef.collection('messages');
      await orderCollectionRef.set({'LastMessageDate': DateTime.now().toUtc().millisecondsSinceEpoch});
      await orderDocumentRef.add(chat.toMap());
      log('Message added to Firestore successfully.');
      return PushOrderModel(true, false, null, true);
    } catch (e, stacktrace) {
      log('Error adding order to Firestore: ${e.toString()} $stacktrace');
      return PushOrderModel(false, true, e.toString(), true);
    }
  }

  @override
  Future<Admin?> getAdminData() async {
    try {
      final QuerySnapshot querySnapshot = await _fireStore.collection('Admin').get();
      return querySnapshot.docs.map((doc) {
        return Admin.fromFireStore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList()[0];
    } catch (e) {
      print('Error getting admin data from Firestore: $e');
      return null;
    }
  }

  @override
  Future<List<order_number.Order>> getRunningOrderCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? customerId = prefs.getString("customerId");
    if (customerId != null) {
      final querySnapshot = await _fireStore
          .collection('Orders')
          .doc(customerId)
          .collection("Products")
          .where('status', isEqualTo: 'pending')
          .get();
      List<order_number.Order> orders = [];
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        //log"data: ${data.toString()}");
        order_number.Order order = order_number.Order(
          customerId: data['customerId'],
          orderDate: data['orderDate'],
          products:
              (data['products'] as List<dynamic>).map((productData) => OrderProduct.fromMap(productData)).toList(),
          // deliveryPrice: data['deliveryPrice'],
          totalPrice: data['totalPrice'],
          totalQuantity: data['totalQuantity'],
          status: data['status'],
          phoneNumber: data.containsKey("address") ? data['address'] : "",
        );
        orders.add(order);
      }
      return orders;
    } else {
      return [];
    }
  }
}
