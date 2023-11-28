import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:sendoff/models/Search/category_product.dart';

import '../../../models/category/category.dart';

@immutable
abstract class AllCategoriesState extends Equatable {
  const AllCategoriesState();

  @override
  List<Object> get props => [];
}

class AllCategoriesInitial extends AllCategoriesState {}

class AllCategoriesLoadingState extends AllCategoriesState {}

class AllCategoriesSuccessState extends AllCategoriesState {
  final Stream<List<Category>> allCategoriesStream;

  const AllCategoriesSuccessState(this.allCategoriesStream);
}

class AllCategoriesFailedState extends AllCategoriesState {
  final String message;

  const AllCategoriesFailedState(this.message);
}

class AllCategoryProductInitial extends AllCategoriesState {}

class AllCategoryProductLoadingState extends AllCategoriesState {}

class AllCategoryProductSuccessState extends AllCategoriesState {
  final Stream<List<CategoryProduct>> allCategoriesStream;

  const AllCategoryProductSuccessState(this.allCategoriesStream);
}

class AllCategoryProductFailedState extends AllCategoriesState {
  final String message;

  const AllCategoryProductFailedState(this.message);
}
