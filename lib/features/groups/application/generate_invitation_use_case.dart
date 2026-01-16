import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../domain/repositories/groups_repository.dart';

class GenerateInvitationUseCase {
  final GroupsRepository repository;

  GenerateInvitationUseCase(this.repository);

  Future<Either<Failure, String>> call(String groupId) {
    return repository.generateInvitationLink(groupId);
  }
}
