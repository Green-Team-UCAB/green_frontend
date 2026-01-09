import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_client.dart';

abstract class DiscoveryRemoteDataSource {
  Future<List<dynamic>> searchQuizzes({
    String? query,
    List<String>? categories,
    int page = 1,
    int limit = 20,
  });

  Future<List<dynamic>> getFeaturedQuizzes({int limit = 10});

  Future<List<String>> getCategories();
}

class DiscoveryRemoteDataSourceImpl implements DiscoveryRemoteDataSource {
  final ApiClient apiClient;

  DiscoveryRemoteDataSourceImpl({required this.apiClient});

  Future<Options> _getAuthOptions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  @override
  Future<List<dynamic>> searchQuizzes({
    String? query,
    List<String>? categories,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final options = await _getAuthOptions();

      final Map<String, dynamic> queryParams = {'page': page, 'limit': limit};

      if (query != null && query.isNotEmpty) {
        queryParams['q'] = query;
      }

      if (categories != null && categories.isNotEmpty) {
        queryParams['categories'] = categories;
      }

      final response = await apiClient.get(
        path: '/explore',
        queryParameters: queryParams,
        options: options,
      );

      final data = response.data;

      // ✅ CAMBIO: Si el back responde, devolvemos lo que hay (aunque sea vacío)
      if (data is List) {
        return data;
      } else if (data is Map && data['data'] is List) {
        return data['data'] as List;
      }

      return []; // Si el formato es raro pero no dio error, devolvemos vacío.
    } catch (e) {
      // ⚠️ SOLO EN CASO DE ERROR REAL (Sin conexión/Timeout) usamos Mocks
      log('⚠️ Error Backend /explore: $e. Usando MOCK DATA.');
      await Future.delayed(const Duration(milliseconds: 800));
      return _generateMockQuizzes(10, titlePrefix: "Resultado");
    }
  }

  @override
  Future<List<dynamic>> getFeaturedQuizzes({int limit = 10}) async {
    try {
      final options = await _getAuthOptions();

      final response = await apiClient.get(
        path: '/explore/featured',
        queryParameters: {'limit': limit},
        options: options,
      );

      final data = response.data;

      // ✅ CAMBIO: Devolvemos lista real (vacía o llena)
      if (data is List) {
        return data;
      } else if (data is Map && data['data'] is List) {
        return data['data'] as List;
      }

      return [];
    } catch (e) {
      // ⚠️ SOLO EN CASO DE ERROR REAL usamos Mocks
      log('⚠️ Error Backend /explore/featured: $e. Usando MOCK DATA.');
      await Future.delayed(const Duration(milliseconds: 800));
      return _generateMockQuizzes(5, titlePrefix: "Destacado");
    }
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      final options = await _getAuthOptions();
      final response = await apiClient.get(
        path: '/explore/categories',
        options: options,
      );

      final data = response.data;
      if (data is List) {
        // Convertimos a lista de Strings
        return List<String>.from(data.map((e) => e['name'] ?? e.toString()));
      }

      return [];
    } catch (e) {
      log('⚠️ Error Backend /explore/categories: $e. Usando MOCK DATA.');
      // ⚠️ SOLO EN CASO DE ERROR REAL usamos Mocks de categorías
      return [
        "Matemáticas",
        "Ciencias",
        "Historia",
        "Geografía",
        "Arte",
        "Tecnología",
        "Idiomas",
        "Deportes",
        "Cine y TV",
        "Cultura General",
      ];
    }
  }

  // --- GENERADOR DE DATOS FALSOS (Solo para emergencias) ---
  List<dynamic> _generateMockQuizzes(int count, {String titlePrefix = "Quiz"}) {
    return List.generate(
      count,
      (index) => {
        "id": "mock-id-$index",
        "title": "$titlePrefix #$index: Conocimiento General (MOCK)",
        "description":
            "Este es un dato falso porque falló la conexión al servidor.",
        "coverImageId": "https://picsum.photos/300/200?random=$index",
        "playCount": (index + 1) * 150,
        "category": "General",
        "author": {
          "id": "mock-author-$index",
          "name": "Profesor Mock",
          "avatarUrl": null,
        },
        "createdAt": DateTime.now()
            .subtract(Duration(days: index))
            .toIso8601String(),
        "questionsCount": 10 + index,
      },
    );
  }
}
