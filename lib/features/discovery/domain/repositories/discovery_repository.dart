import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../shared/domain/entities/kahoot_summary.dart';
import '../../../shared/domain/entities/category.dart';

abstract class DiscoveryRepository {
  // Agregamos categoryId opcional
  Future<Either<Failure, List<KahootSummary>>> searchKahoots(
    String query, {
    String? categoryId,
  });

  Future<Either<Failure, List<KahootSummary>>> getFeaturedKahoots();
  Future<Either<Failure, List<Category>>> getCategories();
}
