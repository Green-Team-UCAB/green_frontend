class GameState {
  final String attemptId;
  final int currentSlideIndex;
  final int score;
  final String? startedAt;

  GameState({
    required this.attemptId,
    required this.currentSlideIndex,
    required this.score,
    this.startedAt,
  });
}
