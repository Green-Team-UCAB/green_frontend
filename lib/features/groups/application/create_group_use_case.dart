import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../domain/entities/group_entity.dart';
import '../domain/repositories/groups_repository.dart';

class CreateGroupUseCase {
  final GroupsRepository repository;

  CreateGroupUseCase(this.repository);

  Future<Either<Failure, GroupEntity>> call(String name, String description) {
    return repository.createGroup(name, description);
  }
}
