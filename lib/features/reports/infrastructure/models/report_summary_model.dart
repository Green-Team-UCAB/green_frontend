import '../../domain/entities/report_summary.dart';

class ReportSummaryModel extends ReportSummary {
  const ReportSummaryModel({
    required super.kahootId,
    required super.gameId,
    required super.gameType,
    required super.title,
    required super.completionDate,
    super.finalScore,
    super.rankingPosition,
  });

  factory ReportSummaryModel.fromJson(Map<String, dynamic> json) {
    return ReportSummaryModel(
      kahootId: json['kahootId'] ?? '',
      gameId: json['gameId'] ?? '',
      // "Singleplayer" | "Multiplayer_player" | "Multiplayer_host"
      gameType: json['gameType'] ?? 'Singleplayer',
      title: json['title'] ?? 'Sin título',
      completionDate:
          DateTime.tryParse(json['completionDate'] ?? '') ?? DateTime.now(),
      finalScore: json['finalScore'],
      rankingPosition: json['rankingPosition'],
    );
  }
}
