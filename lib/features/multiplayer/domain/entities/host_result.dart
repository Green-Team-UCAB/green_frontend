import 'package:green_frontend/features/multiplayer/domain/entities/leaderboard.dart';  

class HostResults {
  final List<String> correctAnswerIds;
  final List<LeaderboardEntry> leaderboard;
  final Map<String, int> distributionTop3;
  final int currentQuestion;
  final int totalQuestions;
  final bool isLastSlide;

  const HostResults({
    required this.correctAnswerIds,
    required this.leaderboard,
    required this.distributionTop3,
    required this.currentQuestion,
    required this.totalQuestions,
    required this.isLastSlide,
  });
}
