class SessionReport {
  final String reportId;
  final String sessionId;
  final String title;
  final DateTime executionDate;
  final List<PlayerRankingItem> playerRanking;
  final List<QuestionAnalysisItem> questionAnalysis;

  const SessionReport({
    required this.reportId,
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
  final double
  correctPercentage; // Del 0.0 al 1.0 (o 0 a 100 según decidas visualizar)

  const QuestionAnalysisItem({
    required this.questionIndex,
    required this.questionText,
    required this.correctPercentage,
  });
}
