import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../domain/entities/personal_report.dart';
import '../domain/repositories/reports_repository.dart';

class GetMultiplayerResultUseCase {
  final ReportsRepository repository;

  GetMultiplayerResultUseCase(this.repository);

  Future<Either<Failure, PersonalReport>> call(String sessionId) {
    return repository.getMultiplayerResult(sessionId);
  }
}
