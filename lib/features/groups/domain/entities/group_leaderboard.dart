class GroupLeaderboardEntry {
  final String userId;
  final String name;
  final int completedQuizzes;
  final int totalPoints;
  final int position;

  const GroupLeaderboardEntry({
    required this.userId,
    required this.name,
    required this.completedQuizzes,
    required this.totalPoints,
    required this.position,
  });
}
