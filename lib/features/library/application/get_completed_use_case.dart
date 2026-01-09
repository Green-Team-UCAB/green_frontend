import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../domain/entities/kahoot_summary.dart';
import '../domain/repositories/library_repository.dart';

class GetCompletedUseCase {
  final LibraryRepository repository;

  GetCompletedUseCase(this.repository);

  /// Obtiene el historial de kahoots que el usuario ha finalizado
  Future<Either<Failure, List<KahootSummary>>> call() {
    return repository.getCompleted();
  }
}
