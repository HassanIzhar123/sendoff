import 'package:bloc/bloc.dart';
import 'package:sendoff/models/Search/todo_save_model.dart';
import 'package:sendoff/repositories/search/search_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/chats/admin.dart';
import 'todo_state.dart';
import '../../../models/PushOrder/Order.dart' as order_number;

class TodoCubit extends Cubit<TodoState> {
  TodoCubit() : super(SearchLoadingState());

  final _fireStoreService = SearchRepository();

  Future<Admin?> getAdminId() async {
    emit(SearchAdminLoadingState());
    Admin? admin = await _fireStoreService.getAdminData();
    emit(SearchAdminSuccessState(admin));
    return null;
  }

  Future<void> fetchOrderCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? customerId = prefs.getString("customerId");
    //log"searvh customerId: $customerId");
    emit(const SearchOrderCountLoadingState());
    if (customerId != null) {
      List<order_number.Order> orderList = await _fireStoreService.getRunningOrderCount(customerId);
      List<ToDoSaveModel> toDoList = await _fireStoreService.getTodos();
      emit(SearchOrderCountSuccessState(orderList, toDoList));
    } else {
      emit(const SearchOrderCountFailedState("User not logged in"));
    }
  }
}
