import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import '../../../models/cart/push_order_model.dart';
import '../../../models/product/product.dart';

@immutable
abstract class CheckoutState extends Equatable {
  const CheckoutState();

  @override
  List<Object> get props => [];
}

class CheckoutInitial extends CheckoutState {}

class CheckoutLoadingState extends CheckoutState {}

class CheckoutSuccessState extends CheckoutState {
  final List<Product> list;

  const CheckoutSuccessState(this.list);
}

class CheckoutFailedState extends CheckoutState {
  final String message;

  const CheckoutFailedState(this.message);
}


class CheckOutPushOrderLoadingState extends CheckoutState {}

class CheckOutPushOrderSuccessState extends CheckoutState {
  final PushOrderModel pushOrderModel;

  const CheckOutPushOrderSuccessState(this.pushOrderModel);
}

class CheckOutPushOrderFailedState extends CheckoutState {
  final String message;

  const CheckOutPushOrderFailedState(this.message);
}