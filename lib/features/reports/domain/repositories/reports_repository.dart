import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/report_summary.dart';
import '../entities/report_detail.dart';

abstract class ReportsRepository {
  // Método para la lista
  Future<Either<Failure, List<ReportSummary>>> getMyResults();

  // Método para el detalle
  Future<Either<Failure, ReportDetail>> getReportDetail(String id);
}
