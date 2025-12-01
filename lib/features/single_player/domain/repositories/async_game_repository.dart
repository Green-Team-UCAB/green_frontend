import 'package:fpdart/fpdart.dart';
import 'package:green_frontend/features/single_player/domain/entities/attempt.dart';
import 'package:green_frontend/features/single_player/domain/entities/answer.dart';
import 'package:green_frontend/features/single_player/domain/entities/answer_result.dart';
import 'package:green_frontend/features/single_player/domain/entities/summary.dart';
import 'package:green_frontend/features/single_player/domain/entities/slide.dart';


abstract interface class AsyncGameRepository {
  Future<(Attempt attempt, Slide firstSlide)> startAttempt(String kahootId);
  Future<(Attempt attempt, Slide? nextSlide)> getAttempt(String attemptId);
  Future<AnswerResult> submitAnswer(String attemptId, Answer answer);
  Future<Summary> getSummary(String attemptId);
}

abstract interface class SoloGameRepositoryFpdart {
  Either<Exception, (Attempt attempt, Slide firstSlide)> startAttempt(String kahootId);
}