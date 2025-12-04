import '../../../shared/data/models/kahoot_summary_model.dart';
import '../../../shared/data/models/category_model.dart';

abstract class DiscoveryRemoteDataSource {
  // Actualizado para aceptar categoryId opcional
  Future<List<KahootSummaryModel>> searchKahoots(
    String query, {
    String? categoryId,
  });
  Future<List<KahootSummaryModel>> getFeaturedKahoots();
  Future<List<CategoryModel>> getCategories();
}

class DiscoveryRemoteDataSourceImpl implements DiscoveryRemoteDataSource {
  @override
  Future<List<KahootSummaryModel>> searchKahoots(
    String query, {
    String? categoryId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Base de datos fake
    final List<KahootSummaryModel> _fakeDatabase = [
      KahootSummaryModel(
        id: '1',
        title: 'Matemáticas Básicas',
        description: 'Suma y Resta',
        authorName: 'Profe Mario',
        status: 'published',
        playCount: 150,
        createdAt: DateTime.now(),
        visibility: 'public',
        coverImageUrl: null,
      ),
      KahootSummaryModel(
        id: '2',
        title: 'Historia de Venezuela',
        description: 'Próceres',
        authorName: 'Historiador123',
        status: 'published',
        playCount: 42,
        createdAt: DateTime.now(),
        visibility: 'public',
        coverImageUrl: null,
      ),
      KahootSummaryModel(
        id: '3',
        title: 'Flutter Avanzado',
        description: 'Bloc y Clean Arch',
        authorName: 'DevMaster',
        status: 'published',
        playCount: 1200,
        createdAt: DateTime.now(),
        visibility: 'public',
        coverImageUrl: null,
      ),
      KahootSummaryModel(
        id: '4',
        title: 'Ciencias Naturales',
        description: 'Biología básica',
        authorName: 'BioTeacher',
        status: 'published',
        playCount: 80,
        createdAt: DateTime.now(),
        visibility: 'public',
        coverImageUrl: null,
      ),
    ];

    // Lógica de filtrado (Simulación)
    return _fakeDatabase.where((k) {
      // 1. Filtro por Texto (Query)
      final matchesQuery =
          query.isEmpty ||
          k.title.toLowerCase().contains(query.toLowerCase()) ||
          k.authorName.toLowerCase().contains(query.toLowerCase());

      // 2. Filtro por Categoría (Simulado buscando la palabra en el título o descripción)
      // En un backend real, esto compararía k.categoryId == categoryId
      final matchesCategory =
          categoryId == null ||
          k.title.toLowerCase().contains(categoryId.toLowerCase()) ||
          k.description.toLowerCase().contains(categoryId.toLowerCase());

      return matchesQuery && matchesCategory;
    }).toList();
  }

  @override
  Future<List<KahootSummaryModel>> getFeaturedKahoots() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      KahootSummaryModel(
        id: 'f1',
        title: 'Trivia de Cine',
        description: '',
        authorName: 'CinemaX',
        status: 'published',
        playCount: 5000,
        createdAt: DateTime.now(),
        visibility: 'public',
      ),
      KahootSummaryModel(
        id: 'f2',
        title: 'Capitales del Mundo',
        description: '',
        authorName: 'GeoMaster',
        status: 'published',
        playCount: 8900,
        createdAt: DateTime.now(),
        visibility: 'public',
      ),
      KahootSummaryModel(
        id: 'f3',
        title: 'Programación 101',
        description: '',
        authorName: 'CodeAcademy',
        status: 'published',
        playCount: 300,
        createdAt: DateTime.now(),
        visibility: 'public',
      ),
    ];
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return [
      const CategoryModel(id: 'c1', name: 'Matemáticas'),
      const CategoryModel(id: 'c2', name: 'Ciencias'),
      const CategoryModel(id: 'c3', name: 'Historia'),
      const CategoryModel(id: 'c4', name: 'Arte'),
      const CategoryModel(id: 'c5', name: 'Tecnología'),
      const CategoryModel(id: 'c6', name: 'Idiomas'),
    ];
  }
}
