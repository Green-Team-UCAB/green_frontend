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
      title: json['title'] ?? 'Resultado',
      userId: json['userId'] ?? '',
      finalScore: (json['finalScore'] as num?)?.toInt() ?? 0,
      correctAnswers: (json['correctAnswers'] as num?)?.toInt() ?? 0,
      totalQuestions: (json['totalQuestions'] as num?)?.toInt() ?? 0,
      averageTimeMs: (json['averageTimeMs'] as num?)?.toInt() ?? 0,
      rankingPosition: (json['rankingPosition'] as num?)?.toInt(),
      questionResults: (json['questionResults'] as List?)
              ?.map((e) => QuestionResultItemModel.fromJson(e))
              .toList() ??
          [],
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
      questionIndex: (json['questionIndex'] as num?)?.toInt() ?? 0,
      questionText: json['questionText'] ?? '',
      isCorrect: json['isCorrect'] ?? false,
      timeTakenMs: (json['timeTakenMs'] as num?)?.toInt() ?? 0,
      // La API devuelve answerText: String[] y answerMediaID: String[]
      answerTexts: (json['answerText'] as List?)?.map((e) => e.toString()).toList() ?? [],
      answerMediaIds: (json['answerMediaID'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}