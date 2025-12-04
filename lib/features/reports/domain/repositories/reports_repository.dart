// CAMBIO: Importamos fpdart en lugar de dartz
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/report_summary.dart';

abstract class ReportsRepository {
  // Either<L, R> funciona igual: Izquierda=Fallo, Derecha=Éxito
  Future<Either<Failure, List<ReportSummary>>> getMyResults();
}
