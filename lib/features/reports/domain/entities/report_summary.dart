class ReportSummary {
  final String kahootId;
  final String gameId;
  final String gameType;
  final String title;
  final DateTime completionDate;
  final int? finalScore;
  final int? rankingPosition;

  const ReportSummary({
    required this.kahootId,
    required this.gameId,
    required this.gameType,
    required this.title,
    required this.completionDate,
    this.finalScore,
    this.rankingPosition,
  });
}
