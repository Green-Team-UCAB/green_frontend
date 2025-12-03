import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kahoot_project/features/kahoot/infrastructure/repositories/mappers/kahoot_mapper.dart';
import 'package:kahoot_project/features/kahoot/domain/entities/kahoot.dart';

class KahootRemoteDataSource {
  final String baseUrl = 'http://tu-api.com';

  // Guarda un Kahoot y devuelve la entidad actualizada
  Future<Kahoot> saveKahoot(Kahoot kahoot) async {
    final Map<String, dynamic> kahootData = KahootMapper.toMap(kahoot);
    
    final response = await http.post(
      Uri.parse('$baseUrl/kahoots'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(kahootData),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return KahootMapper.fromMap(responseData);
    } else {
      throw Exception('Error al guardar kahoot: ${response.statusCode}');
    }
  }
}