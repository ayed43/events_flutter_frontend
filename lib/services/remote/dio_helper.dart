

import 'package:demo/constants.dart';
import 'package:dio/dio.dart';

class DioHelper{
  static Dio dio=Dio();
   static init(){
     dio = Dio(

  BaseOptions(
    baseUrl:serverUrl ,

    receiveDataWhenStatusError: true));
   }
  static Future<Response> getData({
      required String url,
       query
}) async
   {
    return await dio.get(url,queryParameters: query);

   }

}
