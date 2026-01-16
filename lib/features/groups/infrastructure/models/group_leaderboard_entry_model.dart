import '../../domain/entities/group_leaderboard.dart';

class GroupLeaderboardEntryModel extends GroupLeaderboardEntry {
  const GroupLeaderboardEntryModel({
    required super.userId,
    required super.name,
    required super.completedQuizzes,
    required super.totalPoints,
    required super.position,
  });

  factory GroupLeaderboardEntryModel.fromJson(Map<String, dynamic> json) {
    return GroupLeaderboardEntryModel(
      userId: json['userId'] ?? '',
      name: json['name'] ?? 'Usuario',
      completedQuizzes: json['completedQuizzes'] ?? 0,
      totalPoints: json['totalPoints'] ?? 0,
      position: json['position'] ?? 0,
    );
  }
}
