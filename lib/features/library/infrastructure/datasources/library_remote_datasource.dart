import '../../../../core/network/api_client.dart';
import '../models/kahoot_summary_model.dart';

abstract class LibraryRemoteDataSource {
  Future<List<KahootSummaryModel>> getMyCreations();
  Future<List<KahootSummaryModel>> getFavorites();
  Future<List<KahootSummaryModel>> getInProgress();
  Future<List<KahootSummaryModel>> getCompleted();
  Future<void> toggleFavorite(String id, bool isFav);
}

class LibraryRemoteDataSourceImpl implements LibraryRemoteDataSource {
  final ApiClient apiClient;

  LibraryRemoteDataSourceImpl({required this.apiClient});

  Future<List<KahootSummaryModel>> _get(String path) async {
    final response = await apiClient.get(path: path);
    // El back devuelve { "data": [...], "pagination": ... }
    final data = response.data;
    final List list = (data is Map && data['data'] is List) ? data['data'] : [];
    return list.map((e) => KahootSummaryModel.fromJson(e)).toList();
  }

  @override
  Future<List<KahootSummaryModel>> getMyCreations() =>
      _get('/library/my-creations');

  @override
  Future<List<KahootSummaryModel>> getFavorites() => _get('/library/favorites');

  @override
  Future<List<KahootSummaryModel>> getInProgress() =>
      _get('/library/in-progress');

  @override
  Future<List<KahootSummaryModel>> getCompleted() => _get('/library/completed');

  @override
  Future<void> toggleFavorite(String id, bool isFav) async {
    // Si ya es favorito, DELETE. Si no, POST.
    if (isFav) {
      await apiClient.delete(path: '/library/favorites/$id');
    } else {
      await apiClient.post(path: '/library/favorites/$id');
    }
  }
}
