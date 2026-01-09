import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../domain/repositories/groups_repository.dart';

class UpdateGroupUseCase {
  final GroupsRepository repository;

  UpdateGroupUseCase(this.repository);

  Future<Either<Failure, void>> call(
    String groupId,
    String name,
    String description,
  ) {
    return repository.updateGroup(groupId, name, description);
  }
}
