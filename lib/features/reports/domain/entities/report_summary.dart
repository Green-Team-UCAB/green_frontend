class ReportSummary {
  final String kahootId;
  final String gameId; // Puede ser attemptId o sessionId
  final String gameType; // "Singleplayer" | "Multiplayer"
  final String title;
  final DateTime completionDate;
  final int finalScore;
  final int? rankingPosition; // Null en singleplayer

  const ReportSummary({
    required this.kahootId,
    required this.gameId,
    required this.gameType,
    required this.title,
    required this.completionDate,
    required this.finalScore,
    this.rankingPosition,
  });
}
