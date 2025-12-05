import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../shared/domain/entities/kahoot_summary.dart';
import '../../domain/repositories/library_repository.dart';
import '../datasources/library_remote_data_source.dart';

class LibraryRepositoryImpl implements LibraryRepository {
  final LibraryRemoteDataSource remoteDataSource;

  LibraryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<KahootSummary>>> getMyKahoots() async {
    try {
      final result = await remoteDataSource.getMyKahoots();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure('Error cargando mis kahoots: $e'));
    }
  }

  @override
  Future<Either<Failure, List<KahootSummary>>> getFavorites() async {
    try {
      final result = await remoteDataSource.getFavorites();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure('Error cargando favoritos: $e'));
    }
  }
}
