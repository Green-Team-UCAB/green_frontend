import 'package:green_frontend/features/single_player/domain/entities/game_state.dart';

class GameStateModel {
  final String attemptId;
  final int currentSlideIndex;
  final int score;
  final String? startedAt;

  GameStateModel({ required this.attemptId, required this.currentSlideIndex, required this.score, this.startedAt });

  factory GameStateModel.fromJson(Map<String, dynamic> json) => GameStateModel(
    attemptId: json['attemptId'] as String,
    currentSlideIndex: json['currentSlideIndex'] as int,
    score: json['score'] as int? ?? 0,
    startedAt: json['startedAt'] as String?,
  );

  GameState toEntity() {
    return GameState(
      attemptId: attemptId,
      currentSlideIndex: currentSlideIndex,
      score: score,
      startedAt: startedAt,
    );
  }
}