import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/kahoot_summary.dart';

abstract class LibraryRepository {
  Future<Either<Failure, List<KahootSummary>>> getMyKahoots();
  Future<Either<Failure, List<KahootSummary>>> getFavorites();
  Future<Either<Failure, List<KahootSummary>>> getInProgress();
  Future<Either<Failure, List<KahootSummary>>> getCompleted();
  Future<Either<Failure, void>> toggleFavorite(
    String kahootId,
    bool isCurrentlyFavorite,
  );
}
