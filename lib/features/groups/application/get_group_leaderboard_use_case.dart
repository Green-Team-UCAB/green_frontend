import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../domain/entities/group_leaderboard.dart';
import '../domain/repositories/groups_repository.dart';

class GetGroupLeaderboardUseCase {
  final GroupsRepository repository;

  GetGroupLeaderboardUseCase(this.repository);

  Future<Either<Failure, List<GroupLeaderboardEntry>>> call(String groupId) {
    return repository.getGroupLeaderboard(groupId);
  }
}
