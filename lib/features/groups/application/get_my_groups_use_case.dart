import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../domain/entities/group.dart';
import '../domain/repositories/groups_repository.dart';

class GetMyGroupsUseCase {
  final GroupsRepository repository;

  GetMyGroupsUseCase(this.repository);

  Future<Either<Failure, List<Group>>> call() {
    return repository.getMyGroups();
  }
}
