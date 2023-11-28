
import 'package:bloc/bloc.dart';
import '../../../models/cart/push_order_model.dart';
import '../../../models/product/product.dart';
import '../../../repositories/checkout/checkout_repository.dart';
import '../../../models/PushOrder/Order.dart' as order_number;
import 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutRepository meetingRepository;

  CheckoutCubit(this.meetingRepository) : super(CheckoutInitial());
  final _fireStoreService = CheckoutRepository();

  void pushOrder(String? customerId, order_number.Order order) async {
    try {
      emit(CheckOutPushOrderLoadingState());
      PushOrderModel? pushOrderModel = await _fireStoreService.pushOrder(customerId, order);
      if (pushOrderModel != null) {
        if (!pushOrderModel.isError) {
          emit(CheckOutPushOrderSuccessState(pushOrderModel));
        } else {
          emit(CheckOutPushOrderFailedState(pushOrderModel.errorMessage ?? ""));
        }
      } else {
        emit(CheckOutPushOrderFailedState(pushOrderModel != null ? pushOrderModel.errorMessage ?? "" : ""));
      }
    } on Exception {
      emit(const CheckOutPushOrderFailedState("something went wrong"));
    }
  }

  void fetchCheckoutData() async {
    emit(CheckoutLoadingState());
    List<Product> list = await _fireStoreService.getCartList();
    emit(CheckoutSuccessState(list));
  }
}
