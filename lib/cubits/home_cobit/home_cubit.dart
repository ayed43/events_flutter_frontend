

import 'package:demo/services/remote/dio_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../api_models/category_model.dart';
import '../../models/cache_controller/cache_controller.dart';
import 'home_states.dart';

class HomeCubit extends Cubit<HomeStates> {
  HomeCubit() : super(InitialState());


  static HomeCubit get(context) => BlocProvider.of(context);

  List<CategoryModel> categories = [];

  getData(){
    final cache = CacheController();
    final token = cache.token;
    emit(LoadingState());
    DioHelper.getData(url: '/api/home',
    headers: {
       'Authorization':'Bearer ${token}'
    }
    ).then((value){
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