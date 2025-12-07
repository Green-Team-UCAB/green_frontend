import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/report_summary.dart';
import '../entities/report_detail.dart';
import '../entities/session_report.dart';

abstract class ReportsRepository {
  // H10.3: Lista de mis resultados (Jugador)
  Future<Either<Failure, List<ReportSummary>>> getMyResults();

  // H10.3: Detalle de un resultado (Jugador)
  Future<Either<Failure, ReportDetail>> getReportDetail(String id);

  // H10.1: Informe de Sesión (Anfitrión)
  Future<Either<Failure, SessionReport>> getSessionReport(String sessionId);
}
