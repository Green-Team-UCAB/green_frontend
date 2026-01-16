import '../../domain/entities/personal_report.dart';

class PersonalReportModel extends PersonalReport {
  const PersonalReportModel({
    required super.kahootId,
    required super.title,
    required super.userId,
    required super.finalScore,
    required super.correctAnswers,
    required super.totalQuestions,
    required super.averageTimeMs,
    super.rankingPosition,
    required super.questionResults,
  });

  factory PersonalReportModel.fromJson(Map<String, dynamic> json) {
    return PersonalReportModel(
      kahootId: json['kahootId'] ?? '',
      title: json['title'] ?? '',
      userId: json['userId'] ?? '',
      finalScore: json['finalScore'] ?? 0,
      correctAnswers: json['correctAnswers'] ?? 0,
      totalQuestions: json['totalQuestions'] ?? 0,
      averageTimeMs: json['averageTimeMs'] ?? 0,
      rankingPosition: json['rankingPosition'],
      questionResults: (json['questionResults'] as List? ?? [])
          .map((e) => QuestionResultItemModel.fromJson(e))
          .toList(),
    );
  }
}

class QuestionResultItemModel extends QuestionResultItem {
  const QuestionResultItemModel({
    required super.questionIndex,
    required super.questionText,
    required super.isCorrect,
    required super.timeTakenMs,
    required super.answerTexts,
    required super.answerMediaIds,
  });

  factory QuestionResultItemModel.fromJson(Map<String, dynamic> json) {
    return QuestionResultItemModel(
      questionIndex: json['questionIndex'] ?? 0,
      questionText: json['questionText'] ?? '',
      isCorrect: json['isCorrect'] ?? false,
      timeTakenMs: json['timeTakenMs'] ?? 0,
      answerTexts:
          (json['answerText'] as List? ?? []).map((e) => e.toString()).toList(),
      answerMediaIds: (json['answerMediaId'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}
