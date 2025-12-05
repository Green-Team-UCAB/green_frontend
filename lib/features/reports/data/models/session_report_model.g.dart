// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_report_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionReportModel _$SessionReportModelFromJson(Map<String, dynamic> json) =>
    SessionReportModel(
      reportId: json['reportId'] as String,
      sessionId: json['sessionId'] as String,
      title: json['title'] as String,
      executionDate: DateTime.parse(json['executionDate'] as String),
      playerRanking: (json['playerRanking'] as List<dynamic>)
          .map((e) => PlayerRankingModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      questionAnalysis: (json['questionAnalysis'] as List<dynamic>)
          .map((e) => QuestionAnalysisModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SessionReportModelToJson(
  SessionReportModel instance,
) => <String, dynamic>{
  'reportId': instance.reportId,
  'sessionId': instance.sessionId,
  'title': instance.title,
  'executionDate': instance.executionDate.toIso8601String(),
  'playerRanking': instance.playerRanking.map((e) => e.toJson()).toList(),
  'questionAnalysis': instance.questionAnalysis.map((e) => e.toJson()).toList(),
};

PlayerRankingModel _$PlayerRankingModelFromJson(Map<String, dynamic> json) =>
    PlayerRankingModel(
      position: (json['position'] as num).toInt(),
      username: json['username'] as String,
      score: (json['score'] as num).toInt(),
      correctAnswers: (json['correctAnswers'] as num).toInt(),
    );

Map<String, dynamic> _$PlayerRankingModelToJson(PlayerRankingModel instance) =>
    <String, dynamic>{
      'position': instance.position,
      'username': instance.username,
      'score': instance.score,
      'correctAnswers': instance.correctAnswers,
    };

QuestionAnalysisModel _$QuestionAnalysisModelFromJson(
  Map<String, dynamic> json,
) => QuestionAnalysisModel(
  questionIndex: (json['questionIndex'] as num).toInt(),
  questionText: json['questionText'] as String,
  correctPercentage: (json['correctPercentage'] as num).toDouble(),
);

Map<String, dynamic> _$QuestionAnalysisModelToJson(
  QuestionAnalysisModel instance,
) => <String, dynamic>{
  'questionIndex': instance.questionIndex,
  'questionText': instance.questionText,
  'correctPercentage': instance.correctPercentage,
};
