

import 'package:dio/dio.dart';

class DioHelper{
  static Dio dio=Dio();
   static init(){
     dio = Dio(

  BaseOptions(
    baseUrl:'http://10.0.2.2:8000/api/' ,
    // baseUrl:'http://172.0.0.1:8000/api/' ,
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
