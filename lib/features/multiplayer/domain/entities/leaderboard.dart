class LeaderboardEntry { 
  final String playerId; 
  final String nickname; 
  final int score; 
  final int rank; 
  final int previousRank; 

  const LeaderboardEntry({ 
    required this.playerId, 
    required this.nickname, 
    required this.score, 
    required this.rank, 
    required this.previousRank, 
  }); 
}