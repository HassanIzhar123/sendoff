import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

import '../../../models/cart/push_order_model.dart';
import '../../../models/chats/admin.dart';
import '../../../models/PushOrder/Order.dart' as order_number;

@immutable
abstract class ChatsState extends Equatable {
  const ChatsState();

  @override
  List<Object> get props => [];
}

class ChatsInitial extends ChatsState {}

class ChatsLoadingState extends ChatsState {}

class ChatsSuccessState extends ChatsState {
  final Stream<QuerySnapshot<Map<String, dynamic>>> stream;

  const ChatsSuccessState(this.stream);

  @override
  List<Object> get props => [stream];
}

class ChatsFailedState extends ChatsState {
  final String message;

  const ChatsFailedState(this.message);

  @override
  List<Object> get props => [message];
}

class ChatsOrderCountLoadingState extends ChatsState {}

class ChatsOrderCountSuccessState extends ChatsState {
  final List<order_number.Order> orderList;

  const ChatsOrderCountSuccessState(this.orderList);

  @override
  List<Object> get props => [orderList];
}

class ChatsOrderCountFailedState extends ChatsState {
  final String message;

  const ChatsOrderCountFailedState(this.message);

  @override
  List<Object> get props => [message];
}

class ChatsAdminLoadingState extends ChatsState {}

class ChatsAdminSuccessState extends ChatsState {
  final Admin? admin;

  const ChatsAdminSuccessState(this.admin);

  @override
  List<Object> get props => [admin ?? Object];
}

class ChatsAdminFailedState extends ChatsState {
  final String message;

  const ChatsAdminFailedState(this.message);

  @override
  List<Object> get props => [message];
}

class ChatsSendMessageLoadingState extends ChatsState {}

class ChatsSendMessageSuccessState extends ChatsState {
  final PushOrderModel pushOrderModel;

  const ChatsSendMessageSuccessState(this.pushOrderModel);

  @override
  List<Object> get props => [pushOrderModel];
}

class ChatsSendMessageFailedState extends ChatsState {
  final String message;

  const ChatsSendMessageFailedState(this.message);

  @override
  List<Object> get props => [message];
}

class OnOrderPlace extends ChatsState {
  const OnOrderPlace();
}

class ShowIsTalkToHumanError extends ChatsState {
  final int timeStamp;

  const ShowIsTalkToHumanError(this.timeStamp);

  @override
  List<Object> get props => [timeStamp];
}
