import 'package:fpdart/fpdart.dart';
import 'package:green_frontend/core/error/failures.dart';
import 'package:green_frontend/features/auth/domain/entities/user.dart';
import 'package:green_frontend/features/auth/domain/repositories/auth_repository.dart';

class RegisterUserUseCase {
  final AuthRepository repository;

  RegisterUserUseCase(this.repository);

  Future<Either<Failure, User>> call({
    required String userName,
    required String email,
    required String password,
  }) {
    return repository.register(
      userName: userName,
      email: email,
      password: password,
    );
  }
}


