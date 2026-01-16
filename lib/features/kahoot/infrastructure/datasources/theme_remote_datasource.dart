import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:green_frontend/core/storage/token_storage.dart';

class ThemeRemoteDataSource {
  final String baseUrl ='https://quizzy-backend-1-zpvc.onrender.com/api'; //'https://quizzy-backend-0wh2.onrender.com/api';
  final http.Client client;

  ThemeRemoteDataSource({required this.client});

  // Helper para headers con autenticación
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

  Future<List<Map<String, dynamic>>> getThemes() async {
    try {
      final headers = await _getHeaders();

      final response = await client.get(
        Uri.parse('$baseUrl/media/themes'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 404) {
        throw Exception('Endpoint not found: ${response.statusCode}');
      } else {
        throw Exception(
          'Server error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> uploadMedia(
    String filePath,
    String fileName,
  ) async {
    try {
      final token = await TokenStorage.getToken();

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/media/upload'),
      );

      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          filePath,
          filename: fileName,
        ),
      );

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        return json.decode(responseData);
      } else {
        throw Exception(
          'Error al subir media: ${response.statusCode} - $responseData',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}