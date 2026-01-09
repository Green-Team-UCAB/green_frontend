import 'package:fpdart/fpdart.dart';
import 'package:green_frontend/core/error/failures.dart';
import 'package:green_frontend/core/mappers/exception_failure_mapper.dart';
import 'package:green_frontend/features/auth/domain/entities/user.dart';
import 'package:green_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:green_frontend/features/auth/infraestructure/datasources/auth_datasource.dart';
import 'package:green_frontend/features/auth/infraestructure/models/user_model.dart';
import 'package:flutter/foundation.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource dataSource;
  final ExceptionFailureMapper mapper;

  AuthRepositoryImpl({required this.dataSource, required this.mapper});

  @override
  Future<Either<Failure, User>> register({
    required String userName,
    required String email,
    required String password,
  }) async {
    try {
      final model = await dataSource.register(
        userName: userName,
        email: email,
        password: password,
      );
      return right(model.toEntity());
    } on Exception catch (e) {
      debugPrint("AuthRepositoryImpl.register EXCEPTION => $e");
      // debugPrintStack(stackTrace: st);
      final failure = mapper.mapExceptionToFailure(e);
      return left(failure);
    }
  }

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final UserModel model = await dataSource.login(
        email: email,
        password: password,
      );
      final User domain = model.toEntity();
      return right(domain);
    } on Exception catch (e) {
      return left(mapper.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await dataSource.logout();
      return right(unit);
    } on Exception catch (e) {
      return left(mapper.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> resetPassword({required String email}) async {
    try {
      await dataSource.resetPassword(email: email);
      return right(unit);
    } on Exception catch (e) {
      return left(mapper.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile(User user) async {
    try {
      final UserModel model = await dataSource.updateProfile(
        id: user.id,
        body: UserModel.fromEntity(user).toJson(),
      );
      final User domain = model.toEntity();
      return right(domain);
    } on Exception catch (e) {
      return left(mapper.mapExceptionToFailure(e));
    }
  }
}
