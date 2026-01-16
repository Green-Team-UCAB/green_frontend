import 'dart:convert';
import 'package:green_frontend/features/kahoot/domain/entities/kahoot.dart';
import 'package:green_frontend/features/kahoot/infrastructure/repositories/mappers/kahoot_mapper.dart';
import 'package:http/http.dart' as http;
import 'package:green_frontend/core/storage/token_storage.dart';
import 'package:green_frontend/injection_container.dart' as di;

class KahootRemoteDataSource {
  // 🔴 MODIFICADO: Usar URL base desde injection_container
  final String baseUrl = di.apiBaseUrl;

  KahootRemoteDataSource();

  Future<Map<String, String>> _getHeaders() async {
    final headers = {
      'Content-Type': 'application/json',
    };
    final token = await TokenStorage.getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<Kahoot> saveKahoot(Kahoot kahoot) async {
    try {
      if (kahoot.themeId.isEmpty) {
        throw Exception('Debe seleccionar un tema para el Kahoot');
      }

      final uuidRegex = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        caseSensitive: false,
      );
      final isUuidValid = uuidRegex.hasMatch(kahoot.themeId);
      
      if (!isUuidValid) {
        throw Exception(
          'El ID del tema no es un UUID válido: "${kahoot.themeId}"',
        );
      }

      final Map<String, dynamic> kahootData = KahootMapper.toMap(kahoot);

      kahootData.remove('authorId');
      kahootData.remove('createdAt');
      kahootData.remove('playCount');

      final headers = await _getHeaders();

      if (kahoot.id != null && kahoot.id!.isNotEmpty) {
        final Map<String, dynamic> dataForPut = Map<String, dynamic>.from(kahootData);
        dataForPut.remove('id');
        
        final response = await http.put(
          Uri.parse('$baseUrl/kahoots/${kahoot.id}'),
          headers: headers,
          body: json.encode(dataForPut),
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = json.decode(response.body);
          return KahootMapper.fromMap(responseData);
        } else {
          throw Exception(
            'Error al actualizar kahoot: ${response.statusCode} - ${response.body}',
          );
        }
      } else {
        kahootData.remove('id');
        
        final response = await http.post(
          Uri.parse('$baseUrl/kahoots'),
          headers: headers,
          body: json.encode(kahootData),
        );

        if (response.statusCode == 201) {
          final Map<String, dynamic> responseData = json.decode(response.body);
          
          if (responseData["themeId"] == null) {
            if (kahoot.themeId.isNotEmpty) {
              responseData['themeId'] = kahoot.themeId;
            }
          }
          
          return KahootMapper.fromMap(responseData);
        } else {
          throw Exception(
            'Error al guardar kahoot: ${response.statusCode} - ${response.body}',
          );
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // ✅ NUEVO: Obtener un kahoot por ID para editar
  Future<Kahoot> getKahoot(String kahootId) async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/kahoots/$kahootId'),
        headers: headers,
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return KahootMapper.fromMap(responseData);
      } else if (response.statusCode == 404) {
        throw Exception('Kahoot no encontrado: ${response.statusCode}');
      } else {
        throw Exception('Error al obtener kahoot: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // ✅ NUEVO: Obtener un kahoot CON preguntas (endpoint específico si existe)
  Future<Kahoot> getKahootWithQuestions(String kahootId) async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/kahoots/$kahootId?include=questions'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return KahootMapper.fromMap(responseData);
      } else {
        return await getKahoot(kahootId);
      }
    } catch (e) {
      return await getKahoot(kahootId);
    }
  }

  // ✅ NUEVO: Actualizar un kahoot específico
  Future<Kahoot> updateKahoot(Kahoot kahoot) async {
    return await saveKahoot(kahoot); // Reutiliza saveKahoot que maneja PUT
  }

  // Eliminar un kahoot
  Future<void> deleteKahoot(String kahootId) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/kahoots/$kahootId'),
      headers: headers,
    );

    if (response.statusCode != 204) {
      throw Exception('Error al eliminar kahoot: ${response.statusCode}');
    }
  }

  // ✅ NUEVO: Duplicar un kahoot
  Future<Kahoot> duplicateKahoot(String kahootId) async {
    try {
      final originalKahoot = await getKahoot(kahootId);
      
      final duplicatedKahoot = originalKahoot.copyWith(
        id: null,
        title: '${originalKahoot.title} (Copia)',
        playCount: 0,
        createdAt: null,
      );
      
      return await saveKahoot(duplicatedKahoot);
    } catch (e) {
      throw Exception('Error al duplicar kahoot: $e');
    }
  }
}