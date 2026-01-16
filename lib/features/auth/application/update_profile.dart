import 'package:fpdart/fpdart.dart';
import 'package:green_frontend/core/error/failures.dart';
import 'package:green_frontend/features/auth/domain/entities/user.dart';
import 'package:green_frontend/features/auth/domain/repositories/auth_repository.dart';

// features/auth/application/update_profile.dart
class UpdateProfileUseCase {
  final AuthRepository repository;

  UpdateProfileUseCase(this.repository);

  // Usamos .execute para que coincida con tu Bloc
  Future<Either<Failure, User>> execute(Map<String, dynamic> updateData) {
    return repository.updateProfile(updateData);
  }
}