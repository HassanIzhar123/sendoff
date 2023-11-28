import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:sendoff/models/Search/todo_save_model.dart';
import '../../models/PushOrder/OrderProduct.dart';
import '../../models/chats/admin.dart';
import 'base_repository.dart';
import '../../models/PushOrder/Order.dart' as order_number;

class SearchRepository extends BaseRepository {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  List<order_number.Order> orders = [];
  List<ToDoSaveModel> todos = [];

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
  Future<List<order_number.Order>> getRunningOrderCount(String? customerId) async {
    if (customerId != null) {
      final querySnapshot = await _fireStore
          .collection('Orders')
          .doc(customerId)
          .collection("Products")
          .where('status', isEqualTo: 'pending')
          .get();
      orders.clear();
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
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

  Future<List<ToDoSaveModel>> getTodos() async {
    Set<String> uniqueProductIds = <String>{};
    List<ToDoSaveModel> todos = [];

    for (final order in orders) {
      for (final product in order.products) {
        final productId = product.productId;
        if (!uniqueProductIds.contains(productId)) {
          uniqueProductIds.add(productId);
          final todoQuerySnapshot = await _fireStore.collection('products').doc(productId).collection('todo').get();
          final todoList = await Future.wait(todoQuerySnapshot.docs.map((todoDocument) async {
            final todoData = todoDocument.data();
            final taskId = todoDocument.id;
            final taskName = todoData['name'] as String;
            bool isDone = await getIsDone(taskId);
            return ToDoSaveModel(taskId: taskId, taskName: taskName, isDone: isDone);
          }));

          todos.addAll(todoList);
        }
      }
    }
    return todos;
  }

  Future<bool> getIsDone(String taskId) async {
    var box = await Hive.openBox('testBox');
    return box.get(taskId) ?? false;
  }
}
