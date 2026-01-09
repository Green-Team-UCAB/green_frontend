import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../domain/entities/kahoot_summary.dart';
import '../domain/repositories/library_repository.dart';

class GetFavoritesUseCase {
  final LibraryRepository repository;

  GetFavoritesUseCase(this.repository);

  /// Obtiene la lista de kahoots marcados como favoritos
  Future<Either<Failure, List<KahootSummary>>> call() {
    return repository.getFavorites();
  }
}
