import '../../domain/entities/session_report.dart';

class SessionReportModel extends SessionReport {
  const SessionReportModel({
    required super.reportId,
    required super.sessionId,
    required super.title,
    required super.executionDate,
    required super.playerRanking,
    required super.questionAnalysis,
  });

  factory SessionReportModel.fromJson(Map<String, dynamic> json) {
    return SessionReportModel(
      reportId: json['reportId'] ?? '',
      sessionId: json['sessionId'] ?? '',
      title: json['title'] ?? 'Reporte de Sesión',
      executionDate: json['executionDate'] != null
          ? DateTime.parse(json['executionDate'])
          : DateTime.now(),
      playerRanking:
          (json['playerRanking'] as List?)
              ?.map((e) => PlayerRankingItemModel.fromJson(e))
              .toList() ??
          [],
      questionAnalysis:
          (json['questionAnalysis'] as List?)
              ?.map((e) => QuestionAnalysisItemModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class PlayerRankingItemModel extends PlayerRankingItem {
  const PlayerRankingItemModel({
    required super.position,
    required super.username,
    required super.score,
    required super.correctAnswers,
  });

  factory PlayerRankingItemModel.fromJson(Map<String, dynamic> json) {
    return PlayerRankingItemModel(
      position: (json['position'] as num?)?.toInt() ?? 0,
      username: json['username'] ?? 'Anónimo',
      score: (json['score'] as num?)?.toInt() ?? 0,
      correctAnswers: (json['correctAnswers'] as num?)?.toInt() ?? 0,
    );
  }
}

class QuestionAnalysisItemModel extends QuestionAnalysisItem {
  const QuestionAnalysisItemModel({
    required super.questionIndex,
    required super.questionText,
    required super.correctPercentage,
  });

  factory QuestionAnalysisItemModel.fromJson(Map<String, dynamic> json) {
    return QuestionAnalysisItemModel(
      questionIndex: (json['questionIndex'] as num?)?.toInt() ?? 0,
      questionText: json['questionText'] ?? '',
      correctPercentage: (json['correctPercentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
