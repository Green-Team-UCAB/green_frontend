// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportDetailModel _$ReportDetailModelFromJson(Map<String, dynamic> json) =>
    ReportDetailModel(
      kahootId: json['kahootId'] as String,
      title: json['title'] as String,
      finalScore: (json['finalScore'] as num).toInt(),
      correctAnswers: (json['correctAnswers'] as num).toInt(),
      totalQuestions: (json['totalQuestions'] as num).toInt(),
      averageTimeMs: (json['averageTimeMs'] as num).toInt(),
      rankingPosition: (json['rankingPosition'] as num?)?.toInt(),
      questions: (json['questions'] as List<dynamic>)
          .map((e) => QuestionResultModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ReportDetailModelToJson(ReportDetailModel instance) =>
    <String, dynamic>{
      'kahootId': instance.kahootId,
      'title': instance.title,
      'finalScore': instance.finalScore,
      'correctAnswers': instance.correctAnswers,
      'totalQuestions': instance.totalQuestions,
      'averageTimeMs': instance.averageTimeMs,
      'rankingPosition': instance.rankingPosition,
      'questions': instance.questions.map((e) => e.toJson()).toList(),
    };

QuestionResultModel _$QuestionResultModelFromJson(Map<String, dynamic> json) =>
    QuestionResultModel(
      questionIndex: (json['questionIndex'] as num).toInt(),
      questionText: json['questionText'] as String,
      isCorrect: json['isCorrect'] as bool,
      timeTakenMs: (json['timeTakenMs'] as num).toInt(),
      answerText: (json['answerText'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      answerImages: (json['answerMediaID'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$QuestionResultModelToJson(
  QuestionResultModel instance,
) => <String, dynamic>{
  'questionIndex': instance.questionIndex,
  'questionText': instance.questionText,
  'isCorrect': instance.isCorrect,
  'timeTakenMs': instance.timeTakenMs,
  'answerText': instance.answerText,
  'answerMediaID': instance.answerImages,
};
