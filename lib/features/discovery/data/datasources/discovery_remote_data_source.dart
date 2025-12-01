import '../../../shared/data/models/kahoot_summary_model.dart';

abstract class DiscoveryRemoteDataSource {
  Future<List<KahootSummaryModel>> searchKahoots(String query);
}

class DiscoveryRemoteDataSourceImpl implements DiscoveryRemoteDataSource {
  @override
  Future<List<KahootSummaryModel>> searchKahoots(String query) async {
    // Simular delay de red (1 segundo)
    await Future.delayed(const Duration(seconds: 1));

    // Base de datos FAKE en memoria para pruebas
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
        coverImageUrl: 'https://via.placeholder.com/150',
      ),
      KahootSummaryModel(
        id: '2',
        title: 'Historia de Venezuela',
        description: 'Próceres y batallas',
        authorName: 'Historiador123',
        status: 'published',
        playCount: 42,
        createdAt: DateTime.now(),
        visibility: 'public',
        coverImageUrl: 'https://via.placeholder.com/150',
      ),
      KahootSummaryModel(
        id: '3',
        title: 'Flutter vs React Native',
        description: 'Comparativa técnica',
        authorName: 'DevMaster',
        status: 'published',
        playCount: 1200,
        createdAt: DateTime.now(),
        visibility: 'public',
        coverImageUrl: 'https://via.placeholder.com/150',
      ),
    ];

    // Si el query está vacío, devolvemos todo (o nada, según prefieras para UX inicial)
    if (query.isEmpty) return _fakeDatabase;

    // Lógica de filtrado (Case insensitive)
    return _fakeDatabase.where((kahoot) {
      final titleMatch = kahoot.title.toLowerCase().contains(
        query.toLowerCase(),
      );
      final authorMatch = kahoot.authorName.toLowerCase().contains(
        query.toLowerCase(),
      );
      return titleMatch || authorMatch;
    }).toList();
  }
}
