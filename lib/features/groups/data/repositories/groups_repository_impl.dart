import 'package:fpdart/fpdart.dart' hide Group;
import '../../../../core/error/failures.dart';
import '../../domain/entities/group.dart';
import '../../domain/repositories/groups_repository.dart';
import '../datasources/groups_remote_data_source.dart';

class GroupsRepositoryImpl implements GroupsRepository {
  final GroupsRemoteDataSource remoteDataSource;

  GroupsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Group>>> getMyGroups() async {
    try {
      // El DataSource ya maneja el try/catch del mock, así que aquí
      // confiamos en que siempre devolverá una lista (real o falsa)
      final result = await remoteDataSource.getMyGroups();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Group>> createGroup(
    String name,
    String description,
  ) async {
    try {
      final result = await remoteDataSource.createGroup(name, description);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Group>> joinGroup(String token) async {
    try {
      final result = await remoteDataSource.joinGroup(token);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<dynamic>>> getGroupQuizzes(String groupId) async {
    try {
      final result = await remoteDataSource.getGroupQuizzes(groupId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<dynamic>>> getGroupLeaderboard(
    String groupId,
  ) async {
    try {
      final result = await remoteDataSource.getGroupLeaderboard(groupId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> generateInvitation(String groupId) async {
    try {
      final result = await remoteDataSource.generateInvitationLink(groupId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
