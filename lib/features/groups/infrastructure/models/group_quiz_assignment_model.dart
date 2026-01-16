import '../../domain/entities/group_quiz_assignment.dart';

class GroupQuizAssignmentModel extends GroupQuizAssignment {
  const GroupQuizAssignmentModel({
    required super.assignmentId,
    required super.quizId,
    required super.title,
    required super.availableUntil,
    required super.status,
    super.score,
    required super.leaderboard,
  });

  factory GroupQuizAssignmentModel.fromJson(Map<String, dynamic> json) {
    return GroupQuizAssignmentModel(
      assignmentId: json['assignmentId'] ?? json['id'] ?? '',
      quizId: json['quizId'] ?? '',
      title: json['title'] ?? 'Sin título',
      availableUntil:
          DateTime.tryParse(json['availableUntil'] ?? '') ?? DateTime.now(),
      status: json['status'] ?? 'PENDING',
      // userResult puede venir null si status es PENDING
      score: json['userResult'] != null ? json['userResult']['score'] : null,
      leaderboard: json['leaderboard'] != null
          ? (json['leaderboard'] as List)
              .map((e) => GroupQuizLeaderboardItemModel.fromJson(e))
              .toList()
          : [],
    );
  }
}

class GroupQuizLeaderboardItemModel extends GroupQuizLeaderboardItem {
  const GroupQuizLeaderboardItemModel(
      {required super.name, required super.score});

  factory GroupQuizLeaderboardItemModel.fromJson(Map<String, dynamic> json) {
    return GroupQuizLeaderboardItemModel(
      name: json['name'] ?? 'Anónimo',
      score: json['score'] ?? 0,
    );
  }
}
