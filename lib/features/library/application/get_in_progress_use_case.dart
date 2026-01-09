import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../domain/entities/kahoot_summary.dart';
import '../domain/repositories/library_repository.dart';

class GetInProgressUseCase {
  final LibraryRepository repository;

  GetInProgressUseCase(this.repository);

  /// Obtiene la lista de kahoots que el usuario ha pausado o dejado a medias
  Future<Either<Failure, List<KahootSummary>>> call() {
    return repository.getInProgress();
  }
}
