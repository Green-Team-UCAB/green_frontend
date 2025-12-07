import 'package:green_frontend/core/error/exceptions.dart';
import 'package:dio/dio.dart';

class DioErrorHandler {
  static AppException mapException(DioException e) {
    final type = e.type;
    
    // Handle para timeouts
    if (_isTimeout(type)) {
      return NetworkException('Request timeout: ${e.message}');
    }
    
    // Handle para bad responses
    if (type == DioExceptionType.badResponse) {
      return _handleBadResponse(e);
    }
    
    // Handle para cancellation
    if (type == DioExceptionType.cancel) {
      return NetworkException('Request cancelled');
    }
    
    // Handle para connection errors
    if (_isConnectionError(type)) {
      return NetworkException('Connection failed: ${e.message}');
    }
    
    return NetworkException(e.message ?? 'Network error');
  }
  
  static bool _isTimeout(DioExceptionType type) {
    return type == DioExceptionType.connectionTimeout ||
           type == DioExceptionType.sendTimeout ||
           type == DioExceptionType.receiveTimeout;
  }
  
  static bool _isConnectionError(DioExceptionType type) {
    return type == DioExceptionType.connectionError ||
           type == DioExceptionType.unknown;
  }
  
  static AppException _handleBadResponse(DioException e) {
    final status = e.response?.statusCode ?? 500;
    final responseData = e.response?.data;
    final message = _extractErrorMessage(responseData);
    
    switch (status) {
      case 400:
        return BadRequestException(message ?? 'Bad request');
      case 401:
        return UnauthorizedException(message ?? 'Unauthorized');
      case 404:
        return NotFoundException(message ?? 'Resource not found');
      case 409:
        return ConflictException(message ?? 'Conflict detected');
      case 500:
        return ServerException(message ?? 'Internal server error');
      default:
        return ServerException('HTTP $status: ${message ?? 'Unexpected error'}');
    }
  }
  
  static String? _extractErrorMessage(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      return responseData['message']?.toString() ??
             responseData['error']?.toString();
    }
    if (responseData is String) {
      return responseData;
    }
    return null;
  }
}