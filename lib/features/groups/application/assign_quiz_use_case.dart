import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../domain/repositories/groups_repository.dart';

class AssignQuizUseCase {
  final GroupsRepository repository;

  AssignQuizUseCase(this.repository);

  Future<Either<Failure, void>> call(
    String groupId,
    String quizId,
    String availableUntil,
  ) {
    return repository.assignQuiz(groupId, quizId, availableUntil);
  }
}
