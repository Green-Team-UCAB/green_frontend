class SessionReport {
  final String sessionId;
  final String title;
  final DateTime executionDate;
  final List<PlayerRankingItem> playerRanking;
  final List<QuestionAnalysisItem> questionAnalysis;

  const SessionReport({
    required this.sessionId,
    required this.title,
    required this.executionDate,
    required this.playerRanking,
    required this.questionAnalysis,
  });
}

class PlayerRankingItem {
  final int position;
  final String username;
  final int score;
  final int correctAnswers;

  const PlayerRankingItem({
    required this.position,
    required this.username,
    required this.score,
    required this.correctAnswers,
  });
}

class QuestionAnalysisItem {
  final int questionIndex;
  final String questionText;
  final double correctPercentage;

  const QuestionAnalysisItem({
    required this.questionIndex,
    required this.questionText,
    required this.correctPercentage,
  });
}
