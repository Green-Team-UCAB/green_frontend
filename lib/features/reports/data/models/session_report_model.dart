import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/session_report.dart';

part 'session_report_model.g.dart';

@JsonSerializable(explicitToJson: true)
class SessionReportModel extends SessionReport {
  // Sobreescribimos para que el generador use los Modelos en las listas
  @override
  final List<PlayerRankingModel> playerRanking;
  @override
  final List<QuestionAnalysisModel> questionAnalysis;

  const SessionReportModel({
    required super.reportId,
    required super.sessionId,
    required super.title,
    required super.executionDate,
    required this.playerRanking,
    required this.questionAnalysis,
  }) : super(playerRanking: playerRanking, questionAnalysis: questionAnalysis);

  factory SessionReportModel.fromJson(Map<String, dynamic> json) =>
      _$SessionReportModelFromJson(json);

  Map<String, dynamic> toJson() => _$SessionReportModelToJson(this);
}

@JsonSerializable()
class PlayerRankingModel extends PlayerRanking {
  const PlayerRankingModel({
    required super.position,
    required super.username,
    required super.score,
    required super.correctAnswers,
  });

  factory PlayerRankingModel.fromJson(Map<String, dynamic> json) =>
      _$PlayerRankingModelFromJson(json);

  Map<String, dynamic> toJson() => _$PlayerRankingModelToJson(this);
}

@JsonSerializable()
class QuestionAnalysisModel extends QuestionAnalysis {
  const QuestionAnalysisModel({
    required super.questionIndex,
    required super.questionText,
    required super.correctPercentage,
  });

  factory QuestionAnalysisModel.fromJson(Map<String, dynamic> json) =>
      _$QuestionAnalysisModelFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionAnalysisModelToJson(this);
}
