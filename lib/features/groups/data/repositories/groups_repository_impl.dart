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

  @override
  Future<Either<Failure, Group>> editGroup(
    String groupId,
    String name,
    String description,
  ) async {
    try {
      final result = await remoteDataSource.editGroup(
        groupId,
        name,
        description,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeMember(
    String groupId,
    String memberId,
  ) async {
    try {
      await remoteDataSource.removeMember(groupId, memberId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteGroup(String groupId) async {
    try {
      await remoteDataSource.deleteGroup(groupId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ✅ NUEVO H8.6: Implementación de obtener mis kahoots
  @override
  Future<Either<Failure, List<dynamic>>> getMyKahoots() async {
    try {
      final result = await remoteDataSource.getMyKahootsForSelection();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ✅ NUEVO H8.6: Implementación de asignar quiz
  @override
  Future<Either<Failure, void>> assignQuiz(
    String groupId,
    String quizId,
    String availableUntil,
  ) async {
    try {
      await remoteDataSource.assignQuizToGroup(groupId, quizId, availableUntil);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
