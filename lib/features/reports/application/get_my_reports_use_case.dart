import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../domain/entities/report_summary.dart';
import '../domain/repositories/reports_repository.dart';

class GetMyReportSummariesUseCase {
  final ReportsRepository repository;

  GetMyReportSummariesUseCase(this.repository);

  Future<Either<Failure, List<ReportSummary>>> call({
    int page = 1,
    int limit = 20,
  }) {
    return repository.getMyReportSummaries(page: page, limit: limit);
  }
}
