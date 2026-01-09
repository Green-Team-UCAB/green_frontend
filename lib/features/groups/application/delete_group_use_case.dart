import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../domain/repositories/groups_repository.dart';

class DeleteGroupUseCase {
  final GroupsRepository repository;

  DeleteGroupUseCase(this.repository);

  Future<Either<Failure, void>> call(String groupId) {
    return repository.deleteGroup(groupId);
  }
}
