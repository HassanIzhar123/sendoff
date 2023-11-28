import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sendoff/models/cart/push_order_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/PushOrder/Order.dart' as order_number;
import '../../models/product/product.dart';
import 'base_repository.dart';

class CheckoutRepository extends BaseRepository {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  @override
  Future<PushOrderModel?> pushOrder(String? customerId, order_number.Order order) async {
    if (customerId != null) {
      final DocumentReference orderCollectionRef = _fireStore.collection('Orders').doc(customerId);
      final CollectionReference orderDocumentRef = orderCollectionRef.collection('Products');
      try {
        await orderCollectionRef.set({'LastOrderDate': order.orderDate});
        await orderDocumentRef.add(order.toMap());
        log('Order added to Firestore successfully.');
        return PushOrderModel(true, false, null, true);
      } catch (e, stacktrace) {
        log('Error adding order to Firestore: ${e.toString()} $stacktrace');
        return PushOrderModel(false, true, e.toString(), true);
      }
    } else {
      final DocumentReference orderCollectionRef = _fireStore.collection('GuestOrders').doc(_generateCustomerId());
      final CollectionReference orderDocumentRef = orderCollectionRef.collection('Products');
      try {
        await orderCollectionRef.set({'LastOrderDate': order.orderDate});
        await orderDocumentRef.add(order.toMap());
        log('Order added to Firestore successfully.');
        return PushOrderModel(true, false, null, false);
      } catch (e, stacktrace) {
        log('Error adding order to Firestore: ${e.toString()} $stacktrace');
        return PushOrderModel(false, true, e.toString(), false);
      }
    }
  }

  String _generateCustomerId() {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference customers = firestore.collection('GuestOrders');
    DocumentReference documentRef = customers.doc();
    String customerId = documentRef.id;
    return customerId;
  }

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
