import 'package:bloc/bloc.dart';

class SharedCubit extends Cubit<String> {
  SharedCubit() : super('');

  void updateData(String data) {
    emit(data);
  }
}
