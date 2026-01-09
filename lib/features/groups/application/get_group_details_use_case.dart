import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../domain/repositories/groups_repository.dart';

// Definimos una clase simple para devolver múltiples datos si es necesario
// O el repositorio podría devolver un objeto complejo 'GroupDetail'
class GetGroupDetailsUseCase {
  final GroupsRepository repository;

  GetGroupDetailsUseCase(this.repository);

  // Devuelve un mapa con {details, members, quizzes, leaderboard}
  // O una entidad de dominio 'GroupDetail' si la creamos
  Future<Either<Failure, Map<String, dynamic>>> call(String groupId) {
    return repository.getGroupDetails(groupId);
  }
}
