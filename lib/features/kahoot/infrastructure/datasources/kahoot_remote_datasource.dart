import 'dart:convert';
import 'package:green_frontend/features/kahoot/domain/entities/kahoot.dart';
import 'package:green_frontend/features/kahoot/infrastructure/repositories/mappers/kahoot_mapper.dart';
import 'package:http/http.dart' as http;
import 'package:green_frontend/core/storage/token_storage.dart';

class KahootRemoteDataSource {
  final String baseUrl = 'https://quizzy-backend-0wh2.onrender.com/api';

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
      // Validar el kahoot antes de convertirlo
      if (kahoot.themeId.isEmpty) {
        throw Exception('Debe seleccionar un tema para el Kahoot');
      }

      // Validar UUID del themeId
      final uuidRegex = RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
          caseSensitive: false);
      if (!uuidRegex.hasMatch(kahoot.themeId)) {
        throw Exception(
            'El ID del tema no es un UUID válido: ${kahoot.themeId}');
      }

      final Map<String, dynamic> kahootData = KahootMapper.toMap(kahoot);

      // Remover campos que NO se deben enviar
      kahootData.remove('authorId');
      kahootData.remove('createdAt');
      kahootData.remove('playCount');

      final headers = await _getHeaders();
      final jsonString = json.encode(kahootData);

      // Si el kahoot tiene id, es una actualización (PUT)
      if (kahoot.id != null && kahoot.id!.isNotEmpty) {
        final response = await http.put(
          Uri.parse('$baseUrl/kahoots/${kahoot.id}'),
          headers: headers,
          body: jsonString,
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = json.decode(response.body);
          return KahootMapper.fromMap(responseData);
        } else {
          throw Exception(
              'Error al actualizar kahoot: ${response.statusCode} - ${response.body}');
        }
      } else {
        // En creación, no se envía el id
        kahootData.remove('id');
        final response = await http.post(
          Uri.parse('$baseUrl/kahoots'),
          headers: headers,
          body: json.encode(kahootData), // Re-encode as we mutated the map
        );

        if (response.statusCode == 201) {
          final Map<String, dynamic> responseData = json.decode(response.body);
          return KahootMapper.fromMap(responseData);
        } else {
          throw Exception(
              'Error al guardar kahoot: ${response.statusCode} - ${response.body}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Obtener un kahoot por ID
  Future<Kahoot> getKahoot(String kahootId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/kahoots/$kahootId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return KahootMapper.fromMap(responseData);
    } else {
      throw Exception('Error al obtener kahoot: ${response.statusCode}');
    }
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
}
