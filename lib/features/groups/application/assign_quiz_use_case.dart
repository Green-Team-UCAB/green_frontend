import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../domain/repositories/groups_repository.dart';

class AssignQuizUseCase {
  final GroupsRepository repository;

  AssignQuizUseCase(this.repository);

  Future<Either<Failure, void>> call(
    String groupId,
    String quizId,
    DateTime availableFrom,
    DateTime availableUntil,
  ) {
    return repository.assignQuiz(
      groupId: groupId,
      quizId: quizId,
      availableFrom: availableFrom,
      availableUntil: availableUntil,
    );
  }
}
