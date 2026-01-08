import 'package:dartz/dartz.dart';
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
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<KahootSummary>>> getFavorites() async {
    try {
      final result = await remoteDataSource.getFavorites();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<KahootSummary>>> getInProgress() async {
    try {
      final result = await remoteDataSource.getInProgress();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<KahootSummary>>> getCompleted() async {
    try {
      final result = await remoteDataSource.getCompleted();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleFavorite(
    String id,
    bool isFavorite,
  ) async {
    try {
      if (isFavorite) {
        // Si ya era favorito, lo queremos quitar
        await remoteDataSource.removeFromFavorites(id);
      } else {
        // Si no era favorito, lo queremos agregar
        await remoteDataSource.addToFavorites(id);
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
