import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/report_detail.dart';

part 'report_detail_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ReportDetailModel extends ReportDetail {
  @override
  final List<QuestionResultModel> questions;

  const ReportDetailModel({
    required super.kahootId,
    required super.title,
    required super.finalScore,
    required super.correctAnswers,
    required super.totalQuestions,
    required super.averageTimeMs,
    super.rankingPosition,
    required this.questions,
  }) : super(questions: questions);

  factory ReportDetailModel.fromJson(Map<String, dynamic> json) =>
      _$ReportDetailModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReportDetailModelToJson(this);
}

@JsonSerializable()
class QuestionResultModel extends QuestionResult {
  const QuestionResultModel({
    required super.questionIndex,
    required super.questionText,
    required super.isCorrect,
    required super.timeTakenMs,
    // Mapeo opcional por si vienen nulos del backend
    @JsonKey(name: 'answerText') List<String>? answerText,
    @JsonKey(name: 'answerMediaID') List<String>? answerImages,
  }) : super(answerText: answerText, answerImages: answerImages);

  factory QuestionResultModel.fromJson(Map<String, dynamic> json) =>
      _$QuestionResultModelFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionResultModelToJson(this);
}
