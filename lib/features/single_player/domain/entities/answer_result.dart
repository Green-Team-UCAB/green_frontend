import 'package:green_frontend/features/single_player/domain/entities/attempt.dart';
import 'package:green_frontend/features/single_player/domain/entities/slide.dart';

class AnswerResult{
  final bool wasCorrect;
  final int pointsEarned;
  final int updatedScore;
  final AttemptState attemptState;
  final Slide? nextSlide;


  AnswerResult({
    required this.wasCorrect,
    required this.pointsEarned,
    required this.updatedScore,
    required this.attemptState,
    this.nextSlide,
  });

}