import 'package:green_frontend/features/single_player/domain/repositories/async_game_repository.dart';
import 'package:green_frontend/features/single_player/domain/entities/answer_result.dart';
import 'package:green_frontend/features/single_player/domain/entities/answer.dart';

class SummitAnswer {
  final AsyncGameRepository repository;
  SummitAnswer(this.repository);

  Future<AnswerResult> call(String attemptId, Answer userAnswer) {
    return repository.submitAnswer(attemptId, userAnswer);
  }

}
