class PersonalReport {
  final String kahootId;
  final String title;
  final String userId;
  final int finalScore;
  final int correctAnswers;
  final int totalQuestions;
  final int averageTimeMs;
  final int? rankingPosition;
  final List<QuestionResultItem> questionResults;

  const PersonalReport({
    required this.kahootId,
    required this.title,
    required this.userId,
    required this.finalScore,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.averageTimeMs,
    this.rankingPosition,
    required this.questionResults,
  });
}

class QuestionResultItem {
  final int questionIndex;
  final String questionText;
  final bool isCorrect;
  final int timeTakenMs;
  final List<String> answerTexts;
  final List<String> answerMediaIds;

  const QuestionResultItem({
    required this.questionIndex,
    required this.questionText,
    required this.isCorrect,
    required this.timeTakenMs,
    required this.answerTexts,
    required this.answerMediaIds,
  });
}
