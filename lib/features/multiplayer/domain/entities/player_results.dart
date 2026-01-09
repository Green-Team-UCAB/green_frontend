class PlayerResults { 
  final bool isCorrect; 
  final int pointsEarned; 
  final int totalScore; 
  final int rank; 
  final int previousRank; 
  final int streak; 
  final List<String> correctAnswerIds; 
  final int current; 
  final int total; 
  final String? message; 
  
  const PlayerResults({ 
    required this.isCorrect, 
    required this.pointsEarned, 
    required this.totalScore, 
    required this.rank, 
    required this.previousRank, 
    required this.streak, 
    required this.correctAnswerIds, 
    required this.current, 
    required this.total, 
    this.message, 
  }); 
}