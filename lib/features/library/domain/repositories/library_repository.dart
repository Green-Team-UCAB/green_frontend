import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../shared/domain/entities/kahoot_summary.dart';

abstract class LibraryRepository {
  Future<Either<Failure, List<KahootSummary>>> getMyKahoots();
  Future<Either<Failure, List<KahootSummary>>> getFavorites();
  // Nuevos métodos
  Future<Either<Failure, List<KahootSummary>>> getInProgress();
  Future<Either<Failure, List<KahootSummary>>> getCompleted();
  Future<Either<Failure, void>> toggleFavorite(String id, bool isFavorite);
}
