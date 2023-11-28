import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sendoff/models/chats/admin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/cart/push_order_model.dart';
import '../../../models/chats/chat.dart';
import '../../../repositories/chats/chats_repository.dart';
import 'chats_state.dart';
import '../../../models/PushOrder/Order.dart' as order_number;

class ChatsCubit extends Cubit<ChatsState> {
  ChatsCubit() : super(ChatsLoadingState());

  final _fireStoreService = ChatsRepository();

  Future getChatMessages(int messagesPerPage, DocumentSnapshot? lastDocument) async {
    emit(ChatsLoadingState());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? customerId = prefs.getString("customerId");
    if (customerId != null) {
      Stream<QuerySnapshot<Map<String, dynamic>>> stream =
          await _fireStoreService.getChats(customerId, messagesPerPage, lastDocument);
      emit(ChatsSuccessState(stream));
    } else {
      emit(const ChatsFailedState("customer is not signed In"));
    }
  }

  Future sendMessage(String text, int timeStamp) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? customerId = prefs.getString("customerId");
      emit(ChatsSendMessageLoadingState());
      if (customerId != null) {
        Chat chat =
            Chat(displayName: "", text: text, timestamp: timeStamp, uid: customerId, messageId: '', read: false);
        PushOrderModel? pushOrderModel = await _fireStoreService.sendMessage(customerId, chat);
        if (pushOrderModel != null) {
          if (!pushOrderModel.isError) {
            emit(ChatsSendMessageSuccessState(pushOrderModel));
          } else {
            emit(ChatsSendMessageFailedState(pushOrderModel.errorMessage ?? ""));
          }
        } else {
          emit(ChatsSendMessageFailedState(pushOrderModel.errorMessage ?? ""));
        }
      } else {
        emit(const ChatsSendMessageFailedState("customer is not signed In"));
      }
    } on Exception {
      emit(const ChatsSendMessageFailedState("something went wrong"));
    }
  }

  Future<Admin?> getAdminId() async {
    emit(ChatsAdminLoadingState());
    Admin? admin = await _fireStoreService.getAdminData();
    emit(ChatsAdminSuccessState(admin));
    return null;
  }

  void fetchOrderCount() async {
    emit(ChatsOrderCountLoadingState());
    //log"fetchOrderCount");
    List<order_number.Order> orderList = await _fireStoreService.getRunningOrderCount();
    //log"fetchOrderCount1");
    emit(ChatsOrderCountSuccessState(orderList));
  }
}
