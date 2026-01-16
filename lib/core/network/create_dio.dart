import 'package:dio/dio.dart';

Dio createDio({
  required String baseUrl,
  bool enableLogging = false,
  Duration timeout = const Duration(seconds: 8),
}) {
  final dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: timeout,
    receiveTimeout: timeout,
    sendTimeout: timeout,
    contentType: 'application/json',
    responseType: ResponseType.json,
  ));

  if (enableLogging) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );
  }

  return dio;
}