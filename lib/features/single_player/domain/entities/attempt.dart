import 'package:green_frontend/features/single_player/domain/entities/slide.dart';

enum AttemptState {
  inProgress,
  completed,
  unknown,
}

class Attempt {
  final String attemptId;
  final AttemptState state;
  final int currentScore;
  final Slide? nextSlide;
  
  Attempt({
    required this.attemptId,
    required this.state,
    required this.currentScore,
    this.nextSlide,

  });

Attempt copyWith({
    String? attemptId,
    AttemptState? state,
    int? currentScore,
    Slide? nextSlide,
  }) {
    return Attempt(
      attemptId: attemptId ?? this.attemptId,
      state: state ?? this.state,
      currentScore: currentScore ?? this.currentScore,
      nextSlide: nextSlide ?? this.nextSlide,
    );
  }


}