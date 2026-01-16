import 'package:fpdart/fpdart.dart';
import 'package:green_frontend/core/error/failures.dart';
import 'package:green_frontend/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> register({
    required String userName,
    required String email,
    required String password,
    required String name,           
    required String type,           
    String? description,            
    String? avatarAssetUrl,         
  });

  Future<Either<Failure, User>> login({
    required String username,
    required String password,
  });

  Future<Either<Failure, Unit>> logout();

  Future<Either<Failure, Unit>> resetPassword({
    required String email,
  });

  Future<Either<Failure, User>> updateProfile(User user);

  Future<Either<Failure, User>> getUserProfile();
}
