import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../domain/entities/group_quiz_assignment.dart';
import '../domain/repositories/groups_repository.dart';

class GetGroupQuizzesUseCase {
  final GroupsRepository repository;

  GetGroupQuizzesUseCase(this.repository);

  Future<Either<Failure, List<GroupQuizAssignment>>> call(String groupId) {
    return repository.getGroupQuizzes(groupId);
  }
}
