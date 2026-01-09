import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../domain/entities/group_entity.dart';
import '../domain/repositories/groups_repository.dart';

class GetMyGroupsUseCase {
  final GroupsRepository repository;

  GetMyGroupsUseCase(this.repository);

  Future<Either<Failure, List<GroupEntity>>> call() {
    return repository.getMyGroups();
  }
}
