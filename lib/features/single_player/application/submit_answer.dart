import 'package:green_frontend/features/single_player/domain/repositories/async_game_repository.dart';
import 'package:green_frontend/features/single_player/domain/entities/answer_result.dart';
import 'package:green_frontend/features/single_player/domain/entities/answer.dart';
import 'package:fpdart/fpdart.dart';
import 'package:green_frontend/core/error/failures.dart';

class SubmitAnswer {
  final AsyncGameRepository repository;
  SubmitAnswer(this.repository);
  

  Future<Either<Failure,AnswerResult>> call(String attemptId, Answer userAnswer) async {
    if (attemptId.isEmpty) {
      return left(Failure('El ID del intento no puede estar vacío'));
    }
    return await repository.submitAnswer(attemptId:attemptId, answer: userAnswer);
  }

}
