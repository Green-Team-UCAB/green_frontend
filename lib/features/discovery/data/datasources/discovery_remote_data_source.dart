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

      // Soporte para ambos backends en búsqueda
      if (data is List) {
        return data;
      } else if (data is Map && data['data'] is List) {
        return data['data'] as List;
      }

      return [];
    } catch (e) {
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

      // Soporte para ambos backends en destacados
      if (data is List) {
        return data;
      } else if (data is Map && data['data'] is List) {
        return data['data'] as List;
      }

      return [];
    } catch (e) {
      log('⚠️ Error Backend /explore/featured: $e. Usando MOCK DATA.');
      await Future.delayed(const Duration(milliseconds: 800));
      return _generateMockQuizzes(5, titlePrefix: "Destacado");
    }
  }

  // 🔥 AQUÍ ESTÁ EL ARREGLO IMPORTANTE PARA LAS CATEGORÍAS 🔥
  @override
  Future<List<String>> getCategories() async {
    try {
      final options = await _getAuthOptions();
      final response = await apiClient.get(
        path: '/explore/categories',
        options: options,
      );

      final data = response.data;
      List<dynamic> rawList = [];

      // Lógica de unificación:

      // CASO 1: Backend Negro (Array directo) -> [ {...}, {...} ]
      if (data is List) {
        rawList = data;
      }
      // CASO 2: Backend Azul (Objeto con clave) -> { "categories": [ ... ] }
      else if (data is Map && data['categories'] is List) {
        rawList = data['categories'] as List;
      }

      // Procesar la lista limpia
      if (rawList.isNotEmpty) {
        return List<String>.from(rawList.map((e) {
          // Si el elemento es un mapa {"name": "Arte"}
          if (e is Map) {
            return e['name']?.toString() ?? 'Sin Nombre';
          }
          // Si el elemento es un string directo "Arte"
          return e.toString();
        }));
      }

      return [];
    } catch (e) {
      log('⚠️ Error Backend /explore/categories: $e. Usando MOCK DATA.');
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

  // --- GENERADOR DE DATOS FALSOS ---
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
        "createdAt":
            DateTime.now().subtract(Duration(days: index)).toIso8601String(),
        "questionsCount": 10 + index,
      },
    );
  }
}
