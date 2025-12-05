class Failure{
  final String message;
  Failure(this.message );
}


class NotFoundFailure extends Failure {
  NotFoundFailure([super.message= 'Not found']);
}
class BadRequestFailure extends Failure {
  BadRequestFailure([super.message = 'Bad request']);
}
class InvalidInputFailure extends Failure {
  InvalidInputFailure([super.message= 'Invalid input']);
}
class NetworkFailure extends Failure { 
  NetworkFailure([super.message = 'Network error']) ; 
}
class ServerFailure extends Failure { 
  ServerFailure([super.message = 'Server error']); 
}
class UnauthorizedFailure extends Failure { 
  UnauthorizedFailure([super.message = 'Unauthorized']); 
}
class UnknownFailure extends Failure{
  UnknownFailure ([super.message = 'Unknown error']);
}