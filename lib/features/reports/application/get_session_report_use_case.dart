import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../domain/entities/session_report.dart';
import '../domain/repositories/reports_repository.dart';

class GetSessionReportUseCase {
  final ReportsRepository repository;

  GetSessionReportUseCase(this.repository);

  Future<Either<Failure, SessionReport>> call(String sessionId) {
    return repository.getSessionReport(sessionId);
  }
}
