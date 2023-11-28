import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:sendoff/models/Search/todo_save_model.dart';
import '../../../models/PushOrder/Order.dart' as order_number;
import '../../../models/chats/admin.dart';

@immutable
abstract class TodoState extends Equatable {
  const TodoState();

  @override
  List<Object> get props => [];
}

class SearchInitial extends TodoState {}

class SearchLoadingState extends TodoState {}

class SearchSuccessState extends TodoState {
  final Stream<QuerySnapshot<Map<String, dynamic>>> stream;

  const SearchSuccessState(this.stream);

  @override
  List<Object> get props => [stream];
}

class SearchFailedState extends TodoState {
  final String message;

  const SearchFailedState(this.message);

  @override
  List<Object> get props => [message];
}

class SearchOrderCountLoadingState extends TodoState {
  const SearchOrderCountLoadingState();

  @override
  List<Object> get props => [];
}

class SearchOrderCountSuccessState extends TodoState {
  final List<order_number.Order> orderList;
  final List<ToDoSaveModel> todoList;

  const SearchOrderCountSuccessState(this.orderList, this.todoList);

  @override
  List<Object> get props => [orderList, todoList];
}

class SearchOrderCountFailedState extends TodoState {
  final String message;

  const SearchOrderCountFailedState(this.message);

  @override
  List<Object> get props => [message];
}

class SearchAdminLoadingState extends TodoState {}

class SearchAdminSuccessState extends TodoState {
  final Admin? admin;

  const SearchAdminSuccessState(this.admin);

  @override
  List<Object> get props => [admin ?? Object];
}

class SearchAdminFailedState extends TodoState {
  final String message;

  const SearchAdminFailedState(this.message);

  @override
  List<Object> get props => [message];
}

class OnOrderPlace extends TodoState {
  const OnOrderPlace();
}
