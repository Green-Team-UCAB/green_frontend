enum AttemptState {
  inProgress,
  completed,
}

class Attempt {
  final String attemptId;
  AttemptState state;
  int currentScore;
  
  Attempt({
    required this.attemptId,
    required this.state,
    required this.currentScore,

  });
}