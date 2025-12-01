import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../shared/domain/entities/kahoot_summary.dart';

abstract class DiscoveryRepository {
  Future<Either<Failure, List<KahootSummary>>> searchKahoots(String query);
}
