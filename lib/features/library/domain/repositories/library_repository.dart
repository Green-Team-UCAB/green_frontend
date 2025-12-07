import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../shared/domain/entities/kahoot_summary.dart';

abstract class LibraryRepository {
  // H7.1: Mis Kahoots creados
  Future<Either<Failure, List<KahootSummary>>> getMyKahoots();

  // H7.2: Mis Favoritos
  Future<Either<Failure, List<KahootSummary>>> getFavorites();
}
