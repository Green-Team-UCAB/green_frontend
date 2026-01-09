import 'package:fpdart/fpdart.dart' hide Group;
import '../../../../core/error/failures.dart';
import '../entities/group.dart';

abstract class GroupsRepository {
  Future<Either<Failure, List<Group>>> getMyGroups();
  Future<Either<Failure, Group>> createGroup(String name, String description);
  Future<Either<Failure, Group>> joinGroup(String token);
}
