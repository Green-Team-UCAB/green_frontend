import 'package:green_frontend/features/multiplayer/domain/entities/leaderboard.dart';
  
class Summary {
  final List<LeaderboardEntry>? finalPodium; // top 3 (solo host)
  final LeaderboardEntry? winner;            // solo host
  final int? totalParticipants;              // solo host
  final int? rank;                           // solo jugador
  final int? totalScore;                     // solo jugador
  final bool? isPodium;                      // solo jugador
  final bool? isWinner;                      // solo jugador
  final int? finalStreak;                    // solo jugador

  const Summary({
    this.finalPodium,
    this.winner,
    this.totalParticipants,
    this.rank,
    this.totalScore,
    this.isPodium,
    this.isWinner,
    this.finalStreak,
  });
}
