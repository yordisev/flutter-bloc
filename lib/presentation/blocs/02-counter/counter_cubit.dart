import 'package:flutter_bloc/flutter_bloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(5);

  void setNumero(int value) {
    emit(state + value);
  }
}
