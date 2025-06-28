import 'package:demo/constants.dart';
import 'package:dio/dio.dart';

class DioHelper {
  static Dio dio = Dio();

  static init() {
    dio = Dio(
      BaseOptions(
        baseUrl: serverUrl,
        receiveDataWhenStatusError: true,
      ),
    );
  }

  static Future<Response> getData({
    required String url,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
    String? bearerToken, // ✅ أضفنا هذا
  }) async {
    final mergedHeaders = {
      ...?headers,
      if (bearerToken != null) 'Authorization': 'Bearer $bearerToken',
    };

    return await dio.get(
      url,
      queryParameters: query,
      options: Options(headers: mergedHeaders),
    );
  }

  static Future<Response> postData({
    required String url,
    Map<String, dynamic>? data,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
    String? bearerToken,
  }) async {
    final mergedHeaders = {
      ...?headers,
      if (bearerToken != null) 'Authorization': 'Bearer $bearerToken',
      'Content-Type': 'application/json',
    };

    return await dio.post(
      url,
      data: data,
      queryParameters: query,
      options: Options(headers: mergedHeaders),
    );
  }
}
