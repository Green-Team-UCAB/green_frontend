import 'package:fpdart/fpdart.dart';
import 'package:green_frontend/core/error/failures.dart';
import 'package:green_frontend/core/mappers/exception_failure_mapper.dart';
import 'package:green_frontend/features/single_player/domain/entities/attempt.dart';
import 'package:green_frontend/features/single_player/domain/entities/answer.dart';
import 'package:green_frontend/features/single_player/domain/entities/answer_result.dart';
import 'package:green_frontend/features/single_player/domain/entities/summary.dart';
import 'package:green_frontend/features/single_player/domain/entities/kahoot.dart';
import 'package:green_frontend/features/single_player/infraestructure/datasources/async_game_datasource.dart';
import 'package:green_frontend/features/single_player/infraestructure/models/answer_model.dart';
import 'package:green_frontend/features/single_player/infraestructure/models/attempt_model.dart';
import 'package:green_frontend/features/single_player/infraestructure/models/answer_result_model.dart';
import 'package:green_frontend/features/single_player/infraestructure/models/summary_model.dart';
import 'package:green_frontend/features/single_player/infraestructure/models/kahoot_model.dart';
import 'package:green_frontend/features/single_player/domain/repositories/async_game_repository.dart';


class AsyncGameRepositoryImpl implements AsyncGameRepository {
  final AsyncGameDataSource dataSource;
  final ExceptionFailureMapper mapper;

  AsyncGameRepositoryImpl({ required this.dataSource, required this.mapper });

  @override
  Future<Either<Failure, Attempt>> startAttempt({ required String kahootId }) async {
    try {
      final AttemptModel model = await dataSource.startAttempt(kahootId: kahootId);
      final Attempt domain = model.toEntity();
      return right(domain);
    } on Exception catch (e) {
      return left(mapper.mapExceptionToFailure(e));
    }

  }

  @override
  Future<Either<Failure, Attempt>> getAttempt({ required String attemptId }) async {
    try {
      final AttemptModel model = await dataSource.getAttempt(attemptId: attemptId);
      final Attempt domain = model.toEntity();
      return right(domain);
    } on Exception catch (e) {
      return left(mapper.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, AnswerResult>> submitAnswer({ required String attemptId, required Answer answer }) async {
    try {
      final answerModel = AnswerModel.fromEntity(answer);
      final AnswerResultModel resultModel = await dataSource.submitAnswer(attemptId: attemptId, answer: answerModel);
      final AnswerResult domain = resultModel.toEntity();
      return right(domain);
    } on Exception catch (e) {
      return left(mapper.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Summary>> getSummary({ required String attemptId }) async {
    try {
      final SummaryModel model = await dataSource.getSummary(attemptId: attemptId);
      final Summary domain = model.toEntity();
      return right(domain);
    } on Exception catch (e) {
      return left(mapper.mapExceptionToFailure(e));
    }
  }

    @override
  Future<Either<Failure, Kahoot>> getKahootPreview({required String kahootId}) async {
    try {
      final KahootModel model = await dataSource.inspectKahoot(kahootId: kahootId);

      final Kahoot domain = model.toEntity();
      return right(domain);
    } on Exception catch (e) {
      return left(mapper.mapExceptionToFailure(e));
    }
  }
}