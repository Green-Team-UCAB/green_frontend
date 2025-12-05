import 'package:green_frontend/features/single_player/domain/entities/attempt.dart';
import 'package:green_frontend/features/single_player/domain/repositories/async_game_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:green_frontend/core/error/failures.dart';

class StartAttempt {
  final AsyncGameRepository repository;
  StartAttempt(this.repository);

  Future<Either<Failure,Attempt>> call({required String kahootId}) async {
    if (kahootId.isEmpty) {
      return left(InvalidInputFailure('kahootId no puede estar vacío'));
    }
    return await repository.startAttempt(kahootId: kahootId);
  }
  
}