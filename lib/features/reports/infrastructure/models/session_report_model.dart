import '../../domain/entities/session_report.dart';

class SessionReportModel extends SessionReport {
  const SessionReportModel({
    required super.sessionId,
    required super.title,
    required super.executionDate,
    required super.playerRanking,
    required super.questionAnalysis,
  });

  factory SessionReportModel.fromJson(Map<String, dynamic> json) {
    return SessionReportModel(
      sessionId: json['sessionId'] ?? '',
      title: json['title'] ?? 'Sin título',
      executionDate:
          DateTime.tryParse(json['executionDate'] ?? '') ?? DateTime.now(),
      playerRanking: (json['playerRanking'] as List? ?? [])
          .map((e) => PlayerRankingItemModel.fromJson(e))
          .toList(),
      questionAnalysis: (json['questionAnalysis'] as List? ?? [])
          .map((e) => QuestionAnalysisItemModel.fromJson(e))
          .toList(),
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
      position: json['position'] ?? 0,
      username: json['username'] ?? 'Anónimo',
      score: json['score'] ?? 0,
      correctAnswers: json['correctAnswers'] ?? 0,
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
    final num percentage = json['correctPercentage'] ?? 0.0;

    return QuestionAnalysisItemModel(
      questionIndex: json['questionIndex'] ?? 0,
      questionText: json['questionText'] ?? '',
      correctPercentage: percentage.toDouble(),
    );
  }
}
