import 'package:green_frontend/features/single_player/domain/entities/attempt.dart';
import 'package:green_frontend/features/single_player/domain/entities/slide.dart';
import 'package:green_frontend/features/single_player/domain/repositories/async_game_repository.dart';

class StartAttempt {
  final AsyncGameRepository repository;
  StartAttempt(this.repository);

  Future<(Attempt attempt, Slide firstSlide)> call(String kahootId ) async {
    return repository.startAttempt(kahootId);
  }
}