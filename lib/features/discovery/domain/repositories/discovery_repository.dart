import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';

abstract class DiscoveryRepository {
  /// Busca quizes públicos con filtros
  Future<Either<Failure, List<dynamic>>> searchQuizzes({
    String? query,
    List<String>? categories,
  });

  /// Obtiene los quizes destacados para el carrusel principal
  Future<Either<Failure, List<dynamic>>> getFeaturedQuizzes();

  /// Obtiene la lista de categorías disponibles
  Future<Either<Failure, List<String>>> getCategories();
}
