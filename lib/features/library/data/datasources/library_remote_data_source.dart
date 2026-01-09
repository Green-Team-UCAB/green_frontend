import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../shared/data/models/kahoot_summary_model.dart';

abstract class LibraryRemoteDataSource {
  Future<List<KahootSummaryModel>> getMyKahoots({int page = 1});
  Future<List<KahootSummaryModel>> getFavorites({int page = 1});
  Future<List<KahootSummaryModel>> getInProgress({int page = 1});
  Future<List<KahootSummaryModel>> getCompleted({int page = 1});

  Future<void> addToFavorites(String kahootId);
  Future<void> removeFromFavorites(String kahootId);
}

class LibraryRemoteDataSourceImpl implements LibraryRemoteDataSource {
  final ApiClient apiClient;

  LibraryRemoteDataSourceImpl({required this.apiClient});

  // Helper para obtener Headers como Map
  Future<Map<String, dynamic>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';

    if (token.isNotEmpty) {
      // Token found
    } else {
      // Token not found
    }

    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  // --- CONSULTAS GET ---

  @override
  Future<List<KahootSummaryModel>> getMyKahoots({int page = 1}) async {
    return _fetchList('/library/my-creations', page: page);
  }

  @override
  Future<List<KahootSummaryModel>> getFavorites({int page = 1}) async {
    return _fetchList('/library/favorites', page: page);
  }

  @override
  Future<List<KahootSummaryModel>> getInProgress({int page = 1}) async {
    return _fetchList('/library/in-progress', page: page);
  }

  @override
  Future<List<KahootSummaryModel>> getCompleted({int page = 1}) async {
    return _fetchList('/library/completed', page: page);
  }

  // --- ACCIONES POST/DELETE ---

  @override
  Future<void> addToFavorites(String kahootId) async {
    final headers = await _getAuthHeaders();

    await apiClient.post(
      path: '/library/favorites/$kahootId',
      options: Options(headers: headers),
    );
  }

  @override
  Future<void> removeFromFavorites(String kahootId) async {
    final headers = await _getAuthHeaders();

    await apiClient.delete(
      path: '/library/favorites/$kahootId',
      options: Options(headers: headers),
    );
  }

  // --- MÉTODO PRIVADO ---
  Future<List<KahootSummaryModel>> _fetchList(
    String endpoint, {
    required int page,
  }) async {
    try {
      final headers = await _getAuthHeaders();

      // Fetching endpoint

      final response = await apiClient.get(
        path: endpoint,
        queryParameters: {'page': page, 'limit': 20},
        options: Options(headers: headers),
      );

      final responseData = response.data;

      // Validamos la estructura { "data": [...] }
      if (responseData is Map && responseData['data'] != null) {
        final List<dynamic> list = responseData['data'];
        return list.map((item) => KahootSummaryModel.fromJson(item)).toList();
      }

      return [];
    } catch (e) {
      // Manejo provisional: El backend devuelve 400/404 cuando no hay datos o el usuario es nuevo.
      // Lo interpretamos como lista vacía para no romper la UI.
      final msg = e.toString();
      if (msg.contains('400') ||
          msg.contains('404') ||
          msg.contains('orchestration error')) {
        // Backend reported error, returning empty list
        return [];
      }
      rethrow;
    }
  }
}
