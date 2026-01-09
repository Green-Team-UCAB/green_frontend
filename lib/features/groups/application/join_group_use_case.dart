import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../domain/entities/group_entity.dart';
import '../domain/repositories/groups_repository.dart';

class JoinGroupUseCase {
  final GroupsRepository repository;

  JoinGroupUseCase(this.repository);

  Future<Either<Failure, GroupEntity>> call(String token) {
    return repository.joinGroup(token);
  }
}
