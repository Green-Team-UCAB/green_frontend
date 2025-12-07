abstract class AppException implements Exception {
  final String message;
  final String? code;
  
  AppException(this.message, [this.code]);
  
  @override
  String toString() => code != null ? '$code: $message' : message;
}

class NotFoundException extends AppException {
  NotFoundException([String message = 'Not found']) : super(message, 'NOT_FOUND');
}

class NetworkException extends AppException {
  NetworkException([String message = 'Network error']) : super(message, 'NETWORK_ERROR');
}

class InvalidInputException extends AppException {
  InvalidInputException([String message = 'Invalid input']) : super(message, 'INVALID_INPUT');
}

class BadRequestException extends AppException {
  BadRequestException([String message = 'Bad Request']) : super(message, 'BAD_REQUEST');
}

class ServerException extends AppException {
  ServerException([String message = 'Server error']) : super(message, 'SERVER_ERROR');
}

class UnauthorizedException extends AppException {
  UnauthorizedException([String message = 'Unauthorized']) : super(message, 'UNAUTHORIZED');
}

class ConflictException extends AppException {
  ConflictException([String message = 'Conflict']) : super(message, 'CONFLICT');
}