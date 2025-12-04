import 'package:equatable/equatable.dart';

class ReportSummary extends Equatable {
  final String kahootId;
  final String gameId; // ID de la sesión o del intento
  final String gameType; // "Singleplayer" | "Multiplayer"
  final String title;
  final DateTime completionDate;
  final int finalScore;
  final int? rankingPosition; // Puede ser null en singleplayer

  const ReportSummary({
    required this.kahootId,
    required this.gameId,
    required this.gameType,
    required this.title,
    required this.completionDate,
    required this.finalScore,
    this.rankingPosition,
  });

  @override
  List<Object?> get props => [
    kahootId,
    gameId,
    gameType,
    title,
    completionDate,
    finalScore,
    rankingPosition,
  ];
}
