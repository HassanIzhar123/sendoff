import 'package:sendoff/models/PushOrder/OrderProduct.dart';

class Order {
  String? customerId;
  int orderDate;
  List<OrderProduct> products;

  // double deliveryPrice;

  @override
  String toString() {
    return 'Order{customerId: $customerId, orderDate: $orderDate, products: $products, totalPrice: $totalPrice, totalQuantity: $totalQuantity, status: $status, address: $phoneNumber}';
  }

  double totalPrice;
  int totalQuantity;
  String status;
  String phoneNumber;

  Order(
      {this.customerId,
      required this.orderDate,
      required this.products,
      // required this.deliveryPrice,
      required this.totalPrice,
      required this.totalQuantity,
      required this.phoneNumber,
      this.status = "Pending"});

  Map<String, dynamic> toMap() {
    final data = {
      'orderDate': orderDate,
      'products': products.map((product) => product.toMap()).toList(),
      // 'deliveryPrice': deliveryPrice,
      'totalPrice': totalPrice,
      'totalQuantity': totalQuantity,
      'status': status,
      'phoneNumber': phoneNumber,
    };
    if (customerId != null) {
      data['customerId'] = customerId!;
    }

    return data;
  }
}
