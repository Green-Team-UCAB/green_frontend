import 'package:fpdart/fpdart.dart' hide Group;
import '../../../../core/error/failures.dart';
import '../entities/group.dart';

abstract class GroupsRepository {
  Future<Either<Failure, List<Group>>> getMyGroups();
  Future<Either<Failure, Group>> createGroup(String name, String description);
  Future<Either<Failure, Group>> joinGroup(String token);

  // Detalle
  Future<Either<Failure, List<dynamic>>> getGroupQuizzes(String groupId);
  Future<Either<Failure, List<dynamic>>> getGroupLeaderboard(String groupId);
  Future<Either<Failure, String>> generateInvitation(String groupId);

  // Gestión
  Future<Either<Failure, Group>> editGroup(
    String groupId,
    String name,
    String description,
  );
  Future<Either<Failure, void>> removeMember(String groupId, String memberId);
  Future<Either<Failure, void>> deleteGroup(String groupId);

  // Asignación
  Future<Either<Failure, List<dynamic>>> getMyKahoots();
  Future<Either<Failure, void>> assignQuiz(
    String groupId,
    String quizId,
    String availableUntil,
  );
}
