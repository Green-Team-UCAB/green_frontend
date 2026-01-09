import 'package:dartz/dartz.dart'; // Para manejar errores (Either)
import '../../../../core/error/failures.dart'; // Asegúrate de tener tu clase Failure
import '../entities/report_summary.dart';
import '../entities/session_report.dart';
import '../entities/personal_report.dart';

abstract class ReportsRepository {
  // H10.3 Lista de historial
  Future<Either<Failure, List<ReportSummary>>> getMyReportSummaries({
    int page = 1,
    int limit = 20,
  });

  // H10.1 & H10.2 Reporte del Host
  Future<Either<Failure, SessionReport>> getSessionReport(String sessionId);

  // H10.3 Detalle Multiplayer
  Future<Either<Failure, PersonalReport>> getMultiplayerResult(
    String sessionId,
  );

  // H10.3 Detalle Singleplayer
  Future<Either<Failure, PersonalReport>> getSingleplayerResult(
    String attemptId,
  );
}
