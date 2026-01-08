class Player { 
  final String playerId; 
  final String nickname; 
  final int score; 
  final int? rank; 
  final int? previousRank; 
  
  const Player({ 
    required this.playerId, 
    required this.nickname, 
    required this.score, 
    this.rank, 
    this.previousRank, 
  }); 
}
