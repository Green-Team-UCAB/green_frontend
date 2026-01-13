import 'package:green_frontend/features/multiplayer/domain/entities/leaderboard.dart';

class LeaderboardModel extends LeaderboardEntry {
  const LeaderboardModel({
    required super.playerId,
    required super.nickname,
    required super.score,
    required super.rank,
    required super.previousRank,
  });

  factory LeaderboardModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardModel(
      playerId: json['playerId'] as String,
      nickname: json['nickname'] as String,
      score: json['score'] as int,
      rank: json['rank'] as int,
      previousRank: json['previousRank'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playerId': playerId,
      'nickname': nickname,
      'score': score,
      'rank': rank,
      'previousRank': previousRank,
    };
  }
  
}