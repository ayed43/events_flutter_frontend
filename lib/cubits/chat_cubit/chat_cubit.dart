import 'package:demo/api_models/providers/provider_model.dart';
import 'package:demo/constants.dart';
import 'package:demo/cubits/chat_cubit/chat_states.dart';
import 'package:demo/models/cache_controller/cache_controller.dart';
import 'package:demo/services/remote/dio_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatCubit extends Cubit<ChatStates>{
  ChatCubit() : super(ChatInitialState());
  static ChatCubit get(context) => BlocProvider.of(context);

  List<Provider> providers = [];

  getProviders()async {
    emit(ChatLoadingProvidersState());
   await Future.delayed(Duration(seconds: 2));
    DioHelper.getData(url: '${serverUrl}/api/providers',
    bearerToken: CacheController().token
    ).then((value){
      // print(value.data);

      final List<dynamic> dataList = value.data; // fix this line to match your API response

      providers = dataList.map((e) => Provider.fromJson(e)).toList();

      emit(ChatSuccessProvidersState());

    }).catchError((error){

      emit(ChatErrorProvidersState());

    });


  }


}