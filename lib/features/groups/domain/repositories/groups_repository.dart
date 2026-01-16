import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/group.dart';
import '../entities/group_quiz_assignment.dart';
import '../entities/group_leaderboard.dart';

abstract class GroupsRepository {
  Future<Either<Failure, List<Group>>> getMyGroups();
  Future<Either<Failure, Group>> createGroup(
    String name,
    String description,
  );
  Future<Either<Failure, Group>> joinGroup(String token);
  Future<Either<Failure, List<GroupQuizAssignment>>> getGroupQuizzes(
      String groupId);
  Future<Either<Failure, List<GroupLeaderboardEntry>>> getGroupLeaderboard(
      String groupId);
  Future<Either<Failure, String>> generateInvitationLink(String groupId);
  Future<Either<Failure, void>> assignQuiz({
    required String groupId,
    required String quizId,
    required DateTime availableFrom,
    required DateTime availableUntil,
  });
  Future<Either<Failure, void>> updateGroup(
    String groupId,
    String name,
    String description,
  );
  Future<Either<Failure, void>> kickMember(String groupId, String memberId);
  Future<Either<Failure, void>> deleteGroup(String groupId);
}
