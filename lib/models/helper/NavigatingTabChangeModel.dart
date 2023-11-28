import '../product/product.dart';

class NavigatingTabChangeModel {
  int position;
  List<Product> ordersList;
  String customerId;

  NavigatingTabChangeModel(this.customerId, this.position, this.ordersList);

  @override
  String toString() {
    return 'NavigatingTabChangeModel{position: $position, ordersList: $ordersList, customerId: $customerId}';
  }
}
