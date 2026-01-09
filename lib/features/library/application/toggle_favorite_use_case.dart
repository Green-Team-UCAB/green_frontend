import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../domain/repositories/library_repository.dart';

class ToggleFavoriteUseCase {
  final LibraryRepository repository;

  ToggleFavoriteUseCase(this.repository);

  /// Marca o desmarca un kahoot como favorito
  /// [kahootId]: El ID del kahoot
  /// [isCurrentlyFavorite]: El estado actual (si es true, se desmarcará; si es false, se marcará)
  Future<Either<Failure, void>> call(
    String kahootId,
    bool isCurrentlyFavorite,
  ) {
    return repository.toggleFavorite(kahootId, isCurrentlyFavorite);
  }
}
