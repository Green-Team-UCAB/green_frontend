import 'package:fpdart/fpdart.dart';
import 'package:green_frontend/features/single_player/domain/entities/attempt.dart';
import 'package:green_frontend/features/single_player/domain/entities/answer.dart';
import 'package:green_frontend/features/single_player/domain/entities/answer_result.dart';
import 'package:green_frontend/features/single_player/domain/entities/summary.dart';
import 'package:green_frontend/core/error/failures.dart';


abstract interface class AsyncGameRepository {
  Future<Either<Failure,Attempt>> startAttempt({required String kahootId});
  Future<Either<Failure,Attempt>> getAttempt({required String attemptId});
  Future<Either<Failure,AnswerResult>> submitAnswer({required String attemptId, required Answer answer});
  Future<Either<Failure,Summary>> getSummary({required String attemptId});
}