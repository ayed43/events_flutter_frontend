

import 'package:demo/api_models/events_model.dart';
import 'package:demo/services/remote/dio_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../api_models/category_model.dart';
import '../../models/cache_controller/cache_controller.dart';
import 'home_states.dart';

class HomeCubit extends Cubit<HomeStates> {
  HomeCubit() : super(InitialState());


  static HomeCubit get(context) => BlocProvider.of(context);

  List<CategoryModel> categories = [];
  List <EventModel> events=[];

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
      List categoriesData = value.data['categories'];
      categories = categoriesData.map((e) => CategoryModel.fromJson(e)).toList();
      List eventData=value.data['events'];
      events = eventData.map((e) => EventModel.fromJson(e)).toList();
      print(events[0].availableSeats);


    }).catchError((error){
      emit(ErrorSTate());
      print(error.toString());
    });
  }


}