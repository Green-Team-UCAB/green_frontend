import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../domain/entities/personal_report.dart';
import '../domain/repositories/reports_repository.dart';

class GetSingleplayerResultUseCase {
  final ReportsRepository repository;

  GetSingleplayerResultUseCase(this.repository);

  Future<Either<Failure, PersonalReport>> call(String attemptId) {
    return repository.getSingleplayerResult(attemptId);
  }
}
