import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/discovery_repository.dart';
import '../datasources/discovery_remote_data_source.dart';

class DiscoveryRepositoryImpl implements DiscoveryRepository {
  final DiscoveryRemoteDataSource remoteDataSource;

  DiscoveryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<dynamic>>> searchQuizzes({
    String? query,
    List<String>? categories,
  }) async {
    try {
      final result = await remoteDataSource.searchQuizzes(
        query: query,
        categories: categories,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<dynamic>>> getFeaturedQuizzes() async {
    try {
      final result = await remoteDataSource.getFeaturedQuizzes();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getCategories() async {
    try {
      final result = await remoteDataSource.getCategories();
      return Right(result);
    } catch (e) {
      // Si falla, devolvemos lista vacía en lugar de error para no romper la UI de filtros
      return const Right([]);
    }
  }
}
