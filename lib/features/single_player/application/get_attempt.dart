import 'package:green_frontend/features/single_player/domain/entities/attempt.dart';
import 'package:green_frontend/features/single_player/domain/entities/slide.dart';
import 'package:green_frontend/features/single_player/domain/repositories/async_game_repository.dart';

class GetAttemptUseCase {
  final AsyncGameRepository repo;
  GetAttemptUseCase(this.repo);

  Future<(Attempt attempt, Slide? nextSlide)> call(String attemptId) {
    return repo.getAttempt(attemptId);
  }
}