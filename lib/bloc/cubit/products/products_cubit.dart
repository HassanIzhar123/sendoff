import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:sendoff/models/product/product.dart';
import '../../../repositories/products/products_repository.dart';
import 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  ProductsRepository meetingRepository;

  ProductsCubit(this.meetingRepository) : super(ProductsInitial());

  final _dataController = StreamController<List<Product>>();

  final _fireStoreService = ProductsRepository();

  void fetchCategoriesData(String categoryID) async {
    try {
      emit(ProductsLoadingState());
      final data = await _fireStoreService.getProductsForCategory(categoryID);
      _dataController.sink.add(data);
      emit(ProductsSuccessState(_dataController.stream));
    } on Exception {
      emit(const ProductsFailedState("something went wrong"));
    }
  }

  void dispose() {
    _dataController.close();
  }
}
