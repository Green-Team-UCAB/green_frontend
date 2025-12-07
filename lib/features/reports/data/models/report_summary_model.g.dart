// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_summary_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportSummaryModel _$ReportSummaryModelFromJson(Map<String, dynamic> json) =>
    ReportSummaryModel(
      kahootId: json['kahootId'] as String,
      gameId: json['gameId'] as String,
      gameType: json['gameType'] as String,
      title: json['title'] as String,
      completionDate: DateTime.parse(json['completionDate'] as String),
      finalScore: (json['finalScore'] as num).toInt(),
      rankingPosition: (json['rankingPosition'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ReportSummaryModelToJson(ReportSummaryModel instance) =>
    <String, dynamic>{
      'kahootId': instance.kahootId,
      'gameId': instance.gameId,
      'gameType': instance.gameType,
      'title': instance.title,
      'completionDate': instance.completionDate.toIso8601String(),
      'finalScore': instance.finalScore,
      'rankingPosition': instance.rankingPosition,
    };
