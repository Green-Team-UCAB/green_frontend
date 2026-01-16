import 'package:fpdart/fpdart.dart';
import 'package:green_frontend/core/error/failures.dart';
import 'package:green_frontend/features/auth/domain/entities/user.dart';
import 'package:green_frontend/features/auth/domain/repositories/auth_repository.dart';

class RegisterUserUseCase {
  final AuthRepository repository;

  RegisterUserUseCase(this.repository);

  Future<Either<Failure, User>> call({
    required String userName,
    required String name,
    required String email,
    required String password,
    required String type,
    String? description,
    String? avatarAssetUrl,
  }) {
    return repository.register(
      userName: userName,
      name: name,
      email: email,
      password: password,
      type: type,
      description: description,
      avatarAssetUrl: avatarAssetUrl,
    );
  }
}
