import 'package:green_frontend/features/single_player/domain/repositories/async_game_repository.dart';
import 'package:green_frontend/features/single_player/domain/entities/summary.dart';

class GetSummary {
  final AsyncGameRepository repository;
  GetSummary(this.repository);

  Future<Summary> call(String attemptId) {
    return repository.getSummary(attemptId);
  }
}