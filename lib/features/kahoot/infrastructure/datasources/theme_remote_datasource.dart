import 'dart:convert';
import 'package:http/http.dart' as http;

class ThemeRemoteDataSource {
  final String baseUrl = 'http://10.0.2.2:3000';
  final http.Client client;

  ThemeRemoteDataSource({required this.client});

  Future<List<Map<String, dynamic>>> getThemes() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/themes'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 404) {
        throw Exception('Endpoint not found: ${response.statusCode}');
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}