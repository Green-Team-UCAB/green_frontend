import 'package:green_frontend/core/error/exceptions.dart';
import 'package:green_frontend/core/error/failures.dart';


class ExceptionFailureMapper {
  static Failure _mapExceptionToFailure(Exception exception) {
    if (exception is NotFoundException) {
      return NotFoundFailure(exception.message);
    }
    if (exception is UnauthorizedException) {
      return UnauthorizedFailure(exception.message);
    }
    if (exception is BadRequestException) {
      return InvalidInputFailure(exception.message);
    }
    if (exception is NetworkException) {
      return NetworkFailure(exception.message);
    }
    if (exception is ServerException) {
      return ServerFailure(exception.message);
    }
    return UnknownFailure(exception.toString(),
    );
  }

  Failure mapExceptionToFailure(Exception exception) => ExceptionFailureMapper._mapExceptionToFailure(exception);
}