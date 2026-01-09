import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../domain/repositories/groups_repository.dart';

class KickMemberUseCase {
  final GroupsRepository repository;

  KickMemberUseCase(this.repository);

  Future<Either<Failure, void>> call(String groupId, String memberId) {
    return repository.kickMember(groupId, memberId);
  }
}
