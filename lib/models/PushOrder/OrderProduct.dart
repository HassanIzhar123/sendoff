class OrderProduct {
  String productName;
  int quantity;
  double price;
  String productId;

  OrderProduct({required this.productId, required this.productName, required this.quantity, required this.price});

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
    };
  }

  @override
  String toString() {
    return 'OrderProduct{productId: $productId,productName: $productName, quantity: $quantity, price: $price}';
  }

  static OrderProduct fromMap(Map<String, dynamic> data) {
    return OrderProduct(
      productId: data['productId'],
      productName: data['productName'],
      quantity: data['quantity'],
      price: data['price'],
    );
  }
}
