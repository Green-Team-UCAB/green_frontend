import '../../domain/entities/report_summary.dart';

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

  factory ReportSummaryModel.fromJson(Map<String, dynamic> json) {
    return ReportSummaryModel(
      kahootId: json['kahootId'] ?? '',
      gameId: json['gameId'] ?? '',
      gameType: json['gameType'] ?? 'Singleplayer',
      title: json['title'] ?? 'Sin título',
      completionDate: json['completionDate'] != null
          ? DateTime.parse(json['completionDate'])
          : DateTime.now(),
      finalScore: (json['finalScore'] as num?)?.toInt() ?? 0,
      rankingPosition: (json['rankingPosition'] as num?)?.toInt(),
    );
  }
}
