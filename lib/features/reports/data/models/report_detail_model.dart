import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/report_detail.dart';

part 'report_detail_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ReportDetailModel extends ReportDetail {
  // Sobreescribimos la lista para asegurar que use el modelo en la serialización
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
  // Definimos campos locales para aplicar @JsonKey
  // Estos campos "ocultan" los del padre para efectos de JSON, pero los pasamos al super
  @JsonKey(name: 'answerText')
  final List<String>? _answerText;

  @JsonKey(name: 'answerMediaID')
  final List<String>? _answerImages;

  const QuestionResultModel({
    required super.questionIndex,
    required super.questionText,
    required super.isCorrect,
    required super.timeTakenMs,
    List<String>? answerText,
    List<String>? answerImages,
  }) : _answerText = answerText,
       _answerImages = answerImages,
       super(answerText: answerText, answerImages: answerImages);

  factory QuestionResultModel.fromJson(Map<String, dynamic> json) =>
      _$QuestionResultModelFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionResultModelToJson(this);

  // Getters para mantener consistencia con json_serializable si fuera necesario
  @override
  List<String>? get answerText => _answerText;

  @override
  List<String>? get answerImages => _answerImages;
}
