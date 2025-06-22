

import 'package:demo/services/remote/dio_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_states.dart';

class HomeCubit extends Cubit<HomeStates> {
  HomeCubit() : super(InitialState());

  static HomeCubit get(context) => BlocProvider.of(context);


  getData(){
    emit(LoadingState());
    DioHelper.getData(url: '/api/home', ).then((value){
      emit(SuccessState());
      print(value.data);

    }).catchError((error){
      emit(ErrorSTate());
      print(error.toString());
    });
  }


}