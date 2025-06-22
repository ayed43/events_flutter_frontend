

import 'package:demo/services/remote/dio_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../api_models/category_model.dart';
import 'home_states.dart';

class HomeCubit extends Cubit<HomeStates> {
  HomeCubit() : super(InitialState());

  static HomeCubit get(context) => BlocProvider.of(context);

  List<CategoryModel> categories = [];

  getData(){
    emit(LoadingState());
    DioHelper.getData(url: '/api/home', ).then((value){
      emit(SuccessState());
      List data = value.data['categories'];
      categories = data.map((e) => CategoryModel.fromJson(e)).toList();
      print(categories[0].name);

    }).catchError((error){
      emit(ErrorSTate());
      print(error.toString());
    });
  }


}