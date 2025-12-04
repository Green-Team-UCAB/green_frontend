import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/report_summary.dart';

part 'report_summary_model.g.dart';

@JsonSerializable()
class ReportSummaryModel extends ReportSummary {
  const ReportSummaryModel({
    required super.kahootId,
    required super.gameId,
    required super.gameType,
    required super.title,
    required super.completionDate,
    required super.finalScore,
    super.rankingPosition,
  });

  factory ReportSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$ReportSummaryModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReportSummaryModelToJson(this);
}
