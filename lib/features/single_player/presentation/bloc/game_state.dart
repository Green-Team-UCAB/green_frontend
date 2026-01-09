import 'package:green_frontend/features/single_player/domain/entities/attempt.dart';



abstract class GameState {}

class GameInitial extends GameState {}

class GameLoading extends GameState {}

class GameInProgress extends GameState {
  final Attempt attempt;
  GameInProgress(this.attempt);
}

class GameError extends GameState {
  final String message;
  GameError(this.message);
}

