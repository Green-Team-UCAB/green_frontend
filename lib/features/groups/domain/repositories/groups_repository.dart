import 'package:fpdart/fpdart.dart' hide Group;
import '../../../../core/error/failures.dart';
import '../entities/group.dart';

abstract class GroupsRepository {
  // Métodos existentes (H8.1, H8.2, H8.3)
  Future<Either<Failure, List<Group>>> getMyGroups();
  Future<Either<Failure, Group>> createGroup(String name, String description);
  Future<Either<Failure, Group>> joinGroup(String token);

  // Métodos de Detalle (H8.7, H8.9, H8.3)
  Future<Either<Failure, List<dynamic>>> getGroupQuizzes(String groupId);
  Future<Either<Failure, List<dynamic>>> getGroupLeaderboard(String groupId);
  Future<Either<Failure, String>> generateInvitation(String groupId);

  // ✅ NUEVOS MÉTODOS DE GESTIÓN (H8.4 y H8.5)
  Future<Either<Failure, Group>> editGroup(
    String groupId,
    String name,
    String description,
  );
  Future<Either<Failure, void>> removeMember(String groupId, String memberId);
  Future<Either<Failure, void>> deleteGroup(String groupId);
}
