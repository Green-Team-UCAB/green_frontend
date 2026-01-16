class GroupQuizAssignment {
  final String assignmentId;
  final String quizId;
  final String title;
  final DateTime availableUntil;
  final String status; // 'PENDING' | 'COMPLETED' | 'EXPIRED'
  final int? score; // Puede ser null si no lo ha jugado

  // Leaderboard interno de ese quiz específico
  final List<GroupQuizLeaderboardItem> leaderboard;

  const GroupQuizAssignment({
    required this.assignmentId,
    required this.quizId,
    required this.title,
    required this.availableUntil,
    required this.status,
    this.score,
    required this.leaderboard,
  });
}

class GroupQuizLeaderboardItem {
  final String name;
  final int score;

  const GroupQuizLeaderboardItem({required this.name, required this.score});
}
