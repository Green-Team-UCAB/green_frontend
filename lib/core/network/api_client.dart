import 'package:dio/dio.dart';
import 'package:green_frontend/core/network/response_normalizer.dart';
import 'package:green_frontend/core/network/dio_error_handler.dart';


class ApiResponse<T> {
  final T data;
  final int statusCode;
  final Map<String, dynamic>? headers;
  
  ApiResponse({
    required this.data,
    required this.statusCode,
    this.headers,
  });
}

class ApiClient {
  final Dio _dio;
  
  ApiClient(this._dio);
  
  factory ApiClient.withBaseUrl(String baseUrl, {Duration? timeout}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: timeout ?? const Duration(seconds: 8),
        receiveTimeout: timeout ?? const Duration(seconds: 8),
        sendTimeout: timeout ?? const Duration(seconds: 8),
      ),
    );
    return ApiClient(dio);
  }
  
  Future<ApiResponse<T>> request<T>({
    required String method,
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.request(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(method: method),
      );
      
      return ApiResponse<T>(
        data: ResponseNormalizer.normalize(response.data),
        statusCode: response.statusCode!,
        headers: response.headers.map,
      );
    } on DioException catch (e) {
      throw DioErrorHandler.mapException(e);
    }
  }
  
  Future<ApiResponse<T>> get<T>({
    required String path,
    Map<String, dynamic>? queryParameters,
  }) async {
    return request<T>(
      method: 'GET',
      path: path,
      queryParameters: queryParameters,
    );
  }
  
  Future<ApiResponse<T>> post<T>({
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return request<T>(
      method: 'POST',
      path: path,
      data: data,
      queryParameters: queryParameters,
    );
  }
}