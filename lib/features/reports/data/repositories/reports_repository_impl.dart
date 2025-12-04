// CAMBIO: Importamos fpdart
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/report_summary.dart';
import '../../domain/repositories/reports_repository.dart';
import '../datasources/reports_remote_data_source.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsRemoteDataSource remoteDataSource;

  ReportsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ReportSummary>>> getMyResults() async {
    try {
      final remoteReports = await remoteDataSource.getMyResults();

      // EN FPDART:
      // Right(valor) crea una instancia exitosa del Either
      return Right(remoteReports);
    } catch (e) {
      // Left(valor) crea una instancia de fallo del Either
      return Left(ServerFailure('Error cargando informes: $e'));
    }
  }
}
