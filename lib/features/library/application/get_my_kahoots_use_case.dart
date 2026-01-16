import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../domain/entities/kahoot_summary.dart';
import '../domain/repositories/library_repository.dart';

class GetMyKahootsUseCase {
  final LibraryRepository repository;

  GetMyKahootsUseCase(this.repository);

  /// Obtiene la lista de kahoots creados por el usuario (Borradores y Publicados)
  Future<Either<Failure, List<KahootSummary>>> call() {
    return repository.getMyKahoots();
  }
}
