import 'package:green_frontend/features/multiplayer/domain/entities/player.dart';

class PlayerModel extends Player {
  const PlayerModel({
    required super.playerId,
    required super.nickname,
    required super.score,
    super.rank,
    super.previousRank,
  });

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      playerId: json['playerId'] as String,
      nickname: json['nickname'] as String,
      score: json['score'] as int? ?? 0,
      rank: json['rank'] as int?,
      previousRank: json['previousRank'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playerId': playerId,
      'nickname': nickname,
      'score': score,
      if (rank != null) 'rank': rank,
      if (previousRank != null) 'previousRank': previousRank,
    };
  }

  Player toEntity() {
    return Player(
      playerId: playerId,
      nickname: nickname,
      score: score,
      rank: rank,
      previousRank: previousRank,
    );
  }
}