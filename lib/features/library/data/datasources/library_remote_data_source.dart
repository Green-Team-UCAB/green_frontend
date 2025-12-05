import '../../../shared/data/models/kahoot_summary_model.dart';

abstract class LibraryRemoteDataSource {
  Future<List<KahootSummaryModel>> getMyKahoots();
  Future<List<KahootSummaryModel>> getFavorites();
}

class LibraryRemoteDataSourceImpl implements LibraryRemoteDataSource {
  @override
  Future<List<KahootSummaryModel>> getMyKahoots() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return [
      KahootSummaryModel(
        id: '101',
        title: 'Mi Primer Kahoot',
        description: 'Prueba de creación',
        authorName: 'Yo (Tú)',
        status: 'published',
        playCount: 5,
        createdAt: DateTime.now(),
        visibility: 'public',
        coverImageUrl:
            'https://via.placeholder.com/150/0000FF/808080?text=My+Quiz',
      ),
      KahootSummaryModel(
        id: '102',
        title: 'Borrador de Matemáticas',
        description: 'Sin terminar',
        authorName: 'Yo (Tú)',
        status: 'draft',
        playCount: 0,
        createdAt: DateTime.now(),
        visibility: 'private',
      ),
    ];
  }

  @override
  Future<List<KahootSummaryModel>> getFavorites() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return [
      KahootSummaryModel(
        id: '201',
        title: 'Química Avanzada',
        description: 'Tabla periódica',
        authorName: 'Profe. Walter',
        status: 'published',
        playCount: 5000,
        createdAt: DateTime.now(),
        visibility: 'public',
        coverImageUrl:
            'https://via.placeholder.com/150/FF0000/FFFFFF?text=Chem',
      ),
    ];
  }
}
