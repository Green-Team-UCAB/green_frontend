import 'package:fpdart/fpdart.dart';
import 'package:green_frontend/features/single_player/domain/entities/attempt.dart';
import 'package:green_frontend/features/single_player/domain/repositories/async_game_repository.dart';
import 'package:green_frontend/core/error/failures.dart';

class GetAttempt {
  final AsyncGameRepository repository;
  GetAttempt(this.repository);

  Future<Either<Failure, Attempt>> call({required String attemptId}) async {
    if (attemptId.isEmpty) {
      return left(InvalidInputFailure('El ID del intento no puede estar vacío'));
    }
    return await repository.getAttempt(attemptId: attemptId);  
  }

}