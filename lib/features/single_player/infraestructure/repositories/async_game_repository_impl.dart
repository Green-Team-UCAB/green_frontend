import 'package:fpdart/fpdart.dart';
import 'package:green_frontend/core/error/failures.dart';
import 'package:green_frontend/features/single_player/domain/entities/attempt.dart';
import 'package:green_frontend/features/single_player/domain/entities/answer.dart';
import 'package:green_frontend/features/single_player/domain/entities/answer_result.dart';
import 'package:green_frontend/features/single_player/domain/entities/summary.dart';
import 'package:green_frontend/features/single_player/infraestructure/datasources/async_game_datasource.dart';
import 'package:green_frontend/features/single_player/infraestructure/models/answer_model.dart';
import 'package:green_frontend/features/single_player/domain/repositories/async_game_repository.dart';

class AsyncGameRepositoryImpl implements AsyncGameRepository {
  final AsyncGameDataSource dataSource;

  AsyncGameRepositoryImpl({ required this.dataSource });

  @override
  Future<Either<Failure, Attempt>> startAttempt({ required String kahootId }) async {
    try {
      final model = await dataSource.startAttempt(kahootId: kahootId);
      final domain = model.toEntity();
      return right(domain); 
    } on InvalidInputException catch (e) {
      return left(InvalidInputFailure(e.message));
    } on UnauthorizedException catch (e) {
      return left(UnauthorizedFailure(e.message));
    } on BadRequestException catch (e) {
      return left(BadRequestFailure(e.message));
    } on NotFoundException catch (e) {
      return left(NotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return left(ServerFailure(e.message));
    } catch (e) {
      return left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Attempt>> getAttempt({ required String attemptId }) async {
    try {
      final model = await dataSource.getAttempt(attemptId: attemptId);
      return right(model.toEntity());
    } on NotFoundException catch (e) {
      return left(NotFoundFailure(e.message));
    } on UnauthorizedException catch (e) {
      return left(UnauthorizedFailure(e.message));
    } on NetworkException catch (e) {
      return left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return left(ServerFailure(e.message));
    } catch (e) {
      return left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, AnswerResult>> submitAnswer({ required String attemptId, required Answer answer }) async {
    try {
      final model = await dataSource.submitAnswer(attemptId: attemptId, answer: AnswerModel.fromEntity(answer));
      return right(model.toEntity());
    } on InvalidInputException catch (e) {
      return left(InvalidInputFailure(e.message));
    } on BadRequestException catch (e) {
      return left(BadRequestFailure(e.message));
    } on NotFoundException catch (e) {
      return left(NotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return left(ServerFailure(e.message));
    } catch (e) {
      return left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Summary>> getSummary({ required String attemptId }) async {
    try {
      final model = await dataSource.getSummary(attemptId: attemptId);
      return right(model.toEntity());
    } on NotFoundException catch (e) {
      return left(NotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return left(ServerFailure(e.message));
    } catch (e) {
      return left(ServerFailure('Unexpected error: $e'));
    }
  }
}