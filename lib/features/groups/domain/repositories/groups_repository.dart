import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/group_entity.dart';

abstract class GroupsRepository {
  // Lista y Creación
  Future<Either<Failure, List<GroupEntity>>> getMyGroups();
  Future<Either<Failure, GroupEntity>> createGroup(
    String name,
    String description,
  );
  Future<Either<Failure, GroupEntity>> joinGroup(String token);

  // Detalles (Devuelve un Mapa con info del grupo, miembros, quizes y ranking)
  Future<Either<Failure, Map<String, dynamic>>> getGroupDetails(String groupId);

  // Acciones Administrativas
  Future<Either<Failure, String>> generateInvitationLink(String groupId);
  Future<Either<Failure, void>> assignQuiz(
    String groupId,
    String quizId,
    String availableUntil, {
    String? quizTitle,
  });
  Future<Either<Failure, void>> updateGroup(
    String groupId,
    String name,
    String description,
  );
  Future<Either<Failure, void>> kickMember(String groupId, String memberId);
  Future<Either<Failure, void>> deleteGroup(String groupId);
}
