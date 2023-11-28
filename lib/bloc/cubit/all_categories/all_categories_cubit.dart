import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:sendoff/models/Search/category_product.dart';
import '../../../repositories/all_categories/all_categories_repository.dart';
import 'all_categories_state.dart';

class AllCategoriesCubit extends Cubit<AllCategoriesState> {
  AllCategoriesRepository meetingRepository;
  final _fireStoreService = AllCategoriesRepository();
  final categoryProductController = StreamController<List<CategoryProduct>>();

  AllCategoriesCubit(this.meetingRepository) : super(AllCategoriesInitial());

  void fetchCategoriesData() async {
    try {
      emit(AllCategoriesLoadingState());
      final data = await _fireStoreService.getCategories();
      emit(AllCategoriesSuccessState(data));
    } on Exception {
      emit(const AllCategoriesFailedState("something went wrong"));
    }
  }

  void fetchCategoryProductData() async {
    try {
      emit(AllCategoryProductInitial());
      final data = await _fireStoreService.getCategoryProducts();
      categoryProductController.sink.add(data);
      emit(AllCategoryProductSuccessState(categoryProductController.stream));
    } on Exception {
      emit(const AllCategoryProductFailedState("something went wrong"));
    }
  }
}
