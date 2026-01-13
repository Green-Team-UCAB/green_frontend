import 'package:green_frontend/features/multiplayer/domain/entities/summary.dart';
import 'package:green_frontend/features/multiplayer/infraestructure/models/leaderboard_model.dart';

class SummaryModel extends Summary {
  const SummaryModel({
    super.finalPodium,
    super.winner,
    super.totalParticipants,
    super.rank,
    super.totalScore,
    super.isPodium,
    super.isWinner,
    super.finalStreak,
  });

  factory SummaryModel.fromJson(Map<String, dynamic> json) {
    return SummaryModel(
      finalPodium: json['finalPodium'] != null
          ? (json['finalPodium'] as List<dynamic>)
              .map((e) => LeaderboardModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      winner: json['winner'] != null
          ? LeaderboardModel.fromJson(json['winner'] as Map<String, dynamic>)
          : null,
      totalParticipants: json['totalParticipants'] as int?,
      rank: json['rank'] as int?,
      totalScore: json['totalScore'] as int?,
      isPodium: json['isPodium'] as bool?,
      isWinner: json['isWinner'] as bool?,
      finalStreak: json['finalStreak'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'finalPodium': finalPodium
          ?.map((e) => (e as LeaderboardModel).toJson())
          .toList(),
      'winner': winner != null ? (winner as LeaderboardModel).toJson() : null,
      'totalParticipants': totalParticipants,
      'rank': rank,
      'totalScore': totalScore,
      'isPodium': isPodium,
      'isWinner': isWinner,
      'finalStreak': finalStreak,
    };
  }
}