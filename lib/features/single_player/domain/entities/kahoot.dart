import 'package:green_frontend/features/single_player/domain/entities/game_state.dart';

class Kahoot {
  final String id;
  final String title;
  final String? description;
  final String? thumbnailUrl;
  final bool isFavorite;
  final bool isInProgress;
  final bool isCompleted;
  final GameState? gameState;

  Kahoot({
    required this.id,
    required this.title,
    this.description,
    this.thumbnailUrl,
    this.isFavorite = false,
    this.isInProgress = false,
    this.isCompleted = false,
    this.gameState,
  });
}