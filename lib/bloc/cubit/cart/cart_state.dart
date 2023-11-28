import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

import '../../../models/product/product.dart';

@immutable
abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object> get props => [];
}

class CartInitial extends CartState {}

class CartLoadingState extends CartState {}

class CartSuccessState extends CartState {
  final List<Product> list;

  const CartSuccessState(this.list);
}

class CartFailedState extends CartState {
  final String message;

  const CartFailedState(this.message);
}
