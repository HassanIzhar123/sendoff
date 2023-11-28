import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

import '../../../models/category/category.dart';

@immutable
abstract class HomePageState extends Equatable {
  const HomePageState();

  @override
  List<Object> get props => [];
}

class HomePageInitial extends HomePageState {}

class HomePageLoadingState extends HomePageState {}

class HomePageSuccessState extends HomePageState {
  final Stream<List<Category>> homePageStream;

  const HomePageSuccessState(this.homePageStream);
}

