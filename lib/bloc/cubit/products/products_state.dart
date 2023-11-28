import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import '../../../models/product/product.dart';

@immutable
abstract class ProductsState extends Equatable {
  const ProductsState();

  @override
  List<Object> get props => [];
}

class ProductsInitial extends ProductsState {}

class ProductsLoadingState extends ProductsState {}

class ProductsSuccessState extends ProductsState {
  final Stream<List<Product>> allCategoriesStream;

  const ProductsSuccessState(this.allCategoriesStream);
}

class ProductsFailedState extends ProductsState {
  final String message;

  const ProductsFailedState(this.message);
}
