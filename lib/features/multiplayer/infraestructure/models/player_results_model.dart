import 'package:green_frontend/features/multiplayer/domain/entities/player_results.dart';

class PlayerResultsModel extends PlayerResults{
  const PlayerResultsModel({
    required super.isCorrect,
    required super.pointsEarned,
    required super.totalScore,
    required super.rank,
    required super.previousRank,
    required super.streak,
    required super.correctAnswerIds,
    required super.current,
    required super.total,
    super.message,
  });

  factory PlayerResultsModel.fromJson(Map<String, dynamic> json) {
    return PlayerResultsModel(
      isCorrect: json['isCorrect'] as bool,
      pointsEarned: json['pointsEarned'] as int,
      totalScore: json['totalScore'] as int,
      rank: json['rank'] as int,
      previousRank: json['previousRank'] as int,
      streak: json['streak'] as int,
      correctAnswerIds:
          List<String>.from(json['correctAnswerIds'] as List<dynamic>),
      current: json['current'] as int,
      total: json['total'] as int,
      message: json['message'] as String?,
    );
  }

}