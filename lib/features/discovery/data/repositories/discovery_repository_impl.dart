import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/discovery_repository.dart';
import '../datasources/discovery_remote_data_source.dart';
import '../../../shared/domain/entities/kahoot_summary.dart';

class DiscoveryRepositoryImpl implements DiscoveryRepository {
  final DiscoveryRemoteDataSource remoteDataSource;

  DiscoveryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<KahootSummary>>> searchKahoots(
    String query,
  ) async {
    try {
      final remoteKahoots = await remoteDataSource.searchKahoots(query);
      return Right(remoteKahoots);
    } catch (e) {
      // En un caso real, aquí manejarías DioException
      return Left(ServerFailure('Error buscando kahoots: $e'));
    }
  }
}
