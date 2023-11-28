import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repositories/home_page/home_page_repository.dart';
import 'home_page_state.dart';

class HomePageCubit extends Cubit<HomePageState> {
  HomePageRepository meetingRepository;

  HomePageCubit(this.meetingRepository) : super(HomePageInitial());

  final _fireStoreService = HomePageRepository();

  void fetchCategoriesData() async {
    emit(HomePageLoadingState());
    final data = await _fireStoreService.getCategories();
    emit(HomePageSuccessState(data));
  }
}
