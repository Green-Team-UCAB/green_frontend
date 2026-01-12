import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:green_frontend/core/storage/token_storage.dart';

class MediaRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  MediaRemoteDataSource({
    required this.client,
    required this.baseUrl,
  });

  Future<Map<String, dynamic>> uploadMedia(String filePath, String fileName) async {
    try {
      final token = await TokenStorage.getToken();
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/media/upload'),
      );

      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.files.add(await http.MultipartFile.fromPath(
        'file',
        filePath,
        filename: fileName,
      ));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        return json.decode(responseData);
      } else {
        throw Exception('Error al subir media: ${response.statusCode} - $responseData');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> getMediaMetadata(String mediaId) async {
    try {
      final token = await TokenStorage.getToken();
      final headers = {
        'Content-Type': 'application/json',
      };

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await client.get(
        Uri.parse('$baseUrl/media/$mediaId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        throw Exception('Media not found');
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> deleteMedia(String mediaId) async {
    try {
      final token = await TokenStorage.getToken();
      final headers = {
        'Content-Type': 'application/json',
      };

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await client.delete(
        Uri.parse('$baseUrl/media/$mediaId'),
        headers: headers,
      );

      if (response.statusCode != 204) {
        throw Exception('Error al eliminar media: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<String> getSignedUrl(String mediaId, {Duration? expiry}) async {
    try {
      final token = await TokenStorage.getToken();
      final headers = {
        'Content-Type': 'application/json',
      };

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final queryParams = <String, String>{};
      if (expiry != null) {
        queryParams['expiresIn'] = expiry.inSeconds.toString();
      }

      final uri = Uri.parse('$baseUrl/media/$mediaId/signed-url').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final response = await client.get(
        uri,
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['url'];
      } else {
        throw Exception('Error al obtener signed URL: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUserMedia() async {
    try {
      final token = await TokenStorage.getToken();
      final headers = {
        'Content-Type': 'application/json',
      };

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await client.get(
        Uri.parse('$baseUrl/media/user'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error al obtener media del usuario: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}