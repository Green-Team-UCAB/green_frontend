import 'package:green_frontend/features/single_player/infraestructure/models/attempt_model.dart';
import 'package:green_frontend/features/single_player/infraestructure/models/summary_model.dart';

abstract class GameState {}

class GameInitial extends GameState {}

class GameLoading extends GameState {}

class GameInProgress extends GameState {
  final AttemptModel attempt;
  GameInProgress(this.attempt);
}

class GameFinished extends GameState {
  final SummaryModel summary;
  GameFinished(this.summary);
}

class GameError extends GameState {
  final String message;
  GameError(this.message);
}
