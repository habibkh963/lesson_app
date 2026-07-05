import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../shared/constatnts.dart';

class DioHelper {
  static late Dio dio;
  // static late BuildContext appContext;
  // static FToast fToast = FToast();

  static init({
    // required BuildContext context,
    String? authorizationHeader,
    String? contentTypeHeader,
  }) {
    // appContext = context;

    dio = Dio(BaseOptions(baseUrl: "${baseUrl}/"));
    // String? locale = CacheHelper.getData(key: 'locale');

    dio.options.headers = {
      'Authorization': "Bearer ${jwtSecret}",
      'Content-Type': 'application/json',
      'device_id': 'deviceToken123456456789',
      'Accept-Language': 'ar',
    };

    if (kDebugMode) {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, request) {
            log("Request: [${options.method}] ${options.uri.toString()}");
            log(
              "Header: [${options.headers}] ${options.uri.toString()}",

              name: "API Header",
            );
            if (options.data != null) {
              log("Request Data: ${options.data}", name: "API REQUEST");
            }
            return request.next(options); // Continue the request
          },
          onResponse: (response, handler) {
            // log(response.data.toString());
            log(
              "Response: [${response.statusCode}] ${response.requestOptions.uri.toString()}",

              name: "API RESPONSE",
            );
            log("Response Data: ${response.data}", name: "API RESPONSE");
            return handler.next(response);
          },
        ),
      );
    }
  }

  static updateHeader() {
    dio.options.headers = {
      'Authorization': "Bearer ${jwtSecret}",
      'Content-Type': 'application/json',
      'device_id': 'deviceToken123456456789',
      'Accept-Language': 'ar',
    };
  }

  static Future<Response> getData({
    required String url,
    Map<String, dynamic>? query,
    Map<String, dynamic>? data,
    agentData,
  }) async {
    final headers = {
      'Authorization': "Bearer ${jwtSecret}",
      'Content-Type': 'application/json',
      'x-fcm-token': 'xfcmToken123456456789',
      if (agentData != null) 'User-Agent': '$agentData/1.0',
    };

    return await dio.get(
      url,
      data: data,
      queryParameters: query,
      options: Options(headers: headers),
    );
  }

  static Future<Response> postData({
    required String url,
    // Map<String, dynamic>? data,
    Map<String, dynamic>? headers,
  }) async {
    final options = Options(
      headers: {
        'accept': '*/*',
        'Authorization': "Bearer ${jwtSecret}",
        'Content-Type': 'application/json',
        'x-fcm-token': 'xfcmToken123456456789',
      },
    );
    final response = await dio.post(
      url,
      // data: data,
      options: options,
    );
    return response;
  }

  static Future<Response> postWithData({
    required String url,
    dynamic data,
    Map<String, dynamic>? headers,
  }) async {
    // log('body $data');
    final options = Options(headers: {'Content-Type': 'application/json'});
    final response = await dio.post(url, data: data, options: options);
    // log(response.data.toString());

    return response;
  }

  static Future<Response> postDataWithFormData({
    required String url,
    required FormData formData,
  }) async {
    final options = Options(
      headers: {
        'Authorization': "Bearer ${jwtSecret}",
        'Content-Type': 'application/json',
        'x-fcm-token': 'xfcmToken123456456789',
      },
    );
    final response = await dio.post(url, data: formData, options: options);
    return response;
  }

  static Future<Response> putDataWithFormData({
    required String url,
    required FormData formData,
  }) async {
    final options = Options(
      headers: {
        'Authorization': "Bearer ${jwtSecret}",
        'Content-Type': 'application/json',
        'x-fcm-token': 'xfcmToken123456456789',
      },
    );

    final response = await dio.put(url, data: formData, options: options);
    return response;
  }

  static Future<Response> putData({
    required String url,
    required Map<String, dynamic> data,
    Map<String, dynamic>? query,
    String? token,
  }) async {
    return dio.put(url, queryParameters: query, data: data);
  }

  static Future<Response> patchData({required String url}) async {
    return dio.patch(
      url,
      options: Options(
        headers: {
          'Authorization': "Bearer ${jwtSecret}",
          'Content-Type': 'application/json',
          'x-fcm-token': 'xfcmToken123456456789',
        },
      ),
    );
  }

  static Future<Response> patchwithData({
    required String url,
    required dynamic data,
  }) async {
    return dio.patch(
      url,
      options: Options(
        headers: {
          'Authorization': "Bearer ${jwtSecret}",
          'Content-Type': 'application/json',
          'x-fcm-token': 'xfcmToken123456456789',
        },
      ),
      data: data,
    );
  }

  static Future<Response> postDataMulti({
    required String url,
    required dynamic data,
  }) async {
    final options = Options(
      headers: {
        'Authorization': "Bearer ${jwtSecret}",
        'Content-Type': 'application/json',
        'x-fcm-token': 'xfcmToken123456456789',
      },
    );
    final response = await dio.post(url, data: data, options: options);
    return response;
  }

  static Future<Response> deleteData({
    required String url,
    Map<String, dynamic>? data,
  }) async {
    final options = Options(
      headers: {
        'Authorization': "Bearer ${jwtSecret}",
        'Content-Type': 'application/json',
        'x-fcm-token': 'xfcmToken123456456789',
      },
    );
    final response = await dio.delete(url, data: data, options: options);
    return response;
  }
}
