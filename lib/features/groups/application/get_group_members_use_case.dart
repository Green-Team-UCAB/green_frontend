import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../domain/entities/group_member.dart';
import '../domain/repositories/groups_repository.dart';

class GetGroupMembersUseCase {
  final GroupsRepository repository;

  GetGroupMembersUseCase(this.repository);

  Future<Either<Failure, List<GroupMember>>> call(String groupId) {
    return repository.getGroupMembers(groupId);
  }
}
