import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../domain/entities/group.dart';
import '../domain/repositories/groups_repository.dart';

class JoinGroupUseCase {
  final GroupsRepository repository;

  JoinGroupUseCase(this.repository);

  Future<Either<Failure, Group>> call(String token) {
    return repository.joinGroup(token);
  }
}
