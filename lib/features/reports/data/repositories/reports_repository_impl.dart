import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/report_summary.dart';
import '../../domain/entities/report_detail.dart';
import '../../domain/entities/session_report.dart'; // Import necesario
import '../../domain/repositories/reports_repository.dart';
import '../datasources/reports_remote_data_source.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsRemoteDataSource remoteDataSource;

  ReportsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ReportSummary>>> getMyResults() async {
    try {
      final remoteReports = await remoteDataSource.getMyResults();
      return Right(remoteReports);
    } catch (e) {
      return Left(ServerFailure('Error cargando lista de informes: $e'));
    }
  }

  @override
  Future<Either<Failure, ReportDetail>> getReportDetail(String id) async {
    try {
      final remoteDetail = await remoteDataSource.getReportDetail(id);
      return Right(remoteDetail);
    } catch (e) {
      return Left(ServerFailure('Error cargando detalle del informe: $e'));
    }
  }

  // ✅ ESTE ES EL MÉTODO QUE FALTABA:
  @override
  Future<Either<Failure, SessionReport>> getSessionReport(
    String sessionId,
  ) async {
    try {
      final remoteReport = await remoteDataSource.getSessionReport(sessionId);
      return Right(remoteReport);
    } catch (e) {
      return Left(ServerFailure('Error cargando reporte de sesión: $e'));
    }
  }
}
