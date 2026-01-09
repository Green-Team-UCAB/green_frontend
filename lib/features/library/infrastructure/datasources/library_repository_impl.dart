import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/kahoot_summary.dart';
import '../../domain/repositories/library_repository.dart';
import '../datasources/library_remote_datasource.dart';

class LibraryRepositoryImpl implements LibraryRepository {
  final LibraryRemoteDataSource dataSource;

  LibraryRepositoryImpl({required this.dataSource});

  Future<Either<Failure, List<KahootSummary>>> _execute(
    Future<List<KahootSummary>> Function() call,
  ) async {
    try {
      final result = await call();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<KahootSummary>>> getMyKahoots() =>
      _execute(() => dataSource.getMyCreations());

  @override
  Future<Either<Failure, List<KahootSummary>>> getFavorites() =>
      _execute(() => dataSource.getFavorites());

  @override
  Future<Either<Failure, List<KahootSummary>>> getInProgress() =>
      _execute(() => dataSource.getInProgress());

  @override
  Future<Either<Failure, List<KahootSummary>>> getCompleted() =>
      _execute(() => dataSource.getCompleted());

  @override
  Future<Either<Failure, void>> toggleFavorite(String id, bool isFav) async {
    try {
      await dataSource.toggleFavorite(id, isFav);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
