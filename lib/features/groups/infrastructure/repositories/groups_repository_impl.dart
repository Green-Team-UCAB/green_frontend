import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';

// Entidades del Dominio
import '../../domain/entities/group.dart';
import '../../domain/entities/group_quiz_assignment.dart';
import '../../domain/entities/group_leaderboard.dart';
import '../../domain/entities/group_member.dart';
import '../../domain/repositories/groups_repository.dart';

// DataSource
import '../datasources/groups_remote_data_source.dart';

class GroupsRepositoryImpl implements GroupsRepository {
  final GroupsRemoteDataSource remoteDataSource;

  GroupsRepositoryImpl({required this.remoteDataSource});

  // --- HELPER PARA MANEJO DE ERRORES ---
  Future<Either<Failure, T>> _performRequest<T>(
    Future<T> Function() request,
  ) async {
    try {
      final result = await request();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ===========================================================================
  // IMPLEMENTACIÓN DE MÉTODOS
  // ===========================================================================

  @override
  Future<Either<Failure, List<Group>>> getMyGroups() {
    return _performRequest(() => remoteDataSource.getMyGroups());
  }

  @override
  Future<Either<Failure, Group>> createGroup(String name, String description) {
    return _performRequest(
        () => remoteDataSource.createGroup(name, description));
  }

  @override
  Future<Either<Failure, Group>> joinGroup(String token) {
    return _performRequest(() => remoteDataSource.joinGroup(token));
  }

  // --- DETALLES ESPECÍFICOS (Aquí se arregla el bug de mezcla de datos) ---

  @override
  Future<Either<Failure, List<GroupQuizAssignment>>> getGroupQuizzes(
      String groupId) {
    // Al llamar a este método específico del DataSource, aseguramos que
    // la URL sea /groups/$groupId/quizzes
    return _performRequest(() => remoteDataSource.getGroupQuizzes(groupId));
  }

  @override
  Future<Either<Failure, List<GroupLeaderboardEntry>>> getGroupLeaderboard(
      String groupId) {
    return _performRequest(() => remoteDataSource.getGroupLeaderboard(groupId));
  }

  @override
  Future<Either<Failure, List<GroupMember>>> getGroupMembers(String groupId) {
    return _performRequest(() => remoteDataSource.getGroupMembers(groupId));
  }

  // --- ACCIONES ADMINISTRATIVAS ---

  @override
  Future<Either<Failure, String>> generateInvitationLink(String groupId) {
    return _performRequest(
        () => remoteDataSource.generateInvitationLink(groupId));
  }

  @override
  Future<Either<Failure, void>> assignQuiz({
    required String groupId,
    required String quizId,
    required DateTime availableFrom,
    required DateTime availableUntil,
  }) {
    return _performRequest(() => remoteDataSource.assignQuiz(
          groupId,
          quizId,
          availableFrom,
          availableUntil,
        ));
  }

  @override
  Future<Either<Failure, void>> updateGroup(
    String groupId,
    String name,
    String description,
  ) {
    return _performRequest(
        () => remoteDataSource.updateGroup(groupId, name, description));
  }

  @override
  Future<Either<Failure, void>> kickMember(String groupId, String memberId) {
    return _performRequest(
        () => remoteDataSource.kickMember(groupId, memberId));
  }

  @override
  Future<Either<Failure, void>> deleteGroup(String groupId) {
    return _performRequest(() => remoteDataSource.deleteGroup(groupId));
  }
}
