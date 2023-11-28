import 'package:bloc/bloc.dart';
import '../../../models/product/product.dart';
import '../../../repositories/cart/cart_repository.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartRepository meetingRepository;

  CartCubit(this.meetingRepository) : super(CartInitial());
  final _fireStoreService = CartRepository();

  void fetchCartData() async {
    emit(CartLoadingState());
    List<Product> list = await _fireStoreService.getCartList();
    emit(CartSuccessState(list));
  }
}
