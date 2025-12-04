import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/discovery_repository.dart';
import '../datasources/discovery_remote_data_source.dart';
import '../../../shared/domain/entities/kahoot_summary.dart';
import '../../../shared/domain/entities/category.dart';

class DiscoveryRepositoryImpl implements DiscoveryRepository {
  final DiscoveryRemoteDataSource remoteDataSource;

  DiscoveryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<KahootSummary>>> searchKahoots(
    String query, {
    String? categoryId,
  }) async {
    try {
      final result = await remoteDataSource.searchKahoots(
        query,
        categoryId: categoryId,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<KahootSummary>>> getFeaturedKahoots() async {
    try {
      final result = await remoteDataSource.getFeaturedKahoots();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Category>>> getCategories() async {
    try {
      final result = await remoteDataSource.getCategories();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
