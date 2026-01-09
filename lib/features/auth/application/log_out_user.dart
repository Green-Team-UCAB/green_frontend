import 'package:fpdart/fpdart.dart';
import 'package:green_frontend/core/error/failures.dart';
import 'package:green_frontend/features/auth/domain/repositories/auth_repository.dart';

class LogoutUserUseCase {
  final AuthRepository repository;

  LogoutUserUseCase(this.repository);

  Future<Either<Failure, Unit>> call() {
    return repository.logout();
  }
}
