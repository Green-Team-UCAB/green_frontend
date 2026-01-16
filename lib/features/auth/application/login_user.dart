import 'package:fpdart/fpdart.dart';
import 'package:green_frontend/core/error/failures.dart';
import 'package:green_frontend/features/auth/domain/entities/user.dart';
import 'package:green_frontend/features/auth/domain/repositories/auth_repository.dart';

class LoginUserUseCase {
  final AuthRepository repository;

  LoginUserUseCase(this.repository);

  Future<Either<Failure, User>> call({
    required String username,
    required String password,
  }) {
    return repository.login(username: username, password: password);
  }
}
