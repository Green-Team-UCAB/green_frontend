import 'package:green_frontend/features/single_player/domain/repositories/async_game_repository.dart';
import 'package:green_frontend/features/single_player/domain/entities/summary.dart';
import 'package:fpdart/fpdart.dart';
import 'package:green_frontend/core/error/failures.dart';


class GetSummary {
  final AsyncGameRepository repository;
  GetSummary(this.repository);

  Future<Either<Failure,Summary>> call(String attemptId) async {
    if (attemptId.isEmpty) {
      return left(InvalidInputFailure('El ID del intento no puede estar vacío'));
    }
    return await repository.getSummary(attemptId: attemptId);
  }
}