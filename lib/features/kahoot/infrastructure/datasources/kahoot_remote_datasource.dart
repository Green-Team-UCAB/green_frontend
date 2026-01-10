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
      final uuidRegex = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$', caseSensitive: false);
      if (!uuidRegex.hasMatch(kahoot.themeId)) {
        throw Exception('El ID del tema no es un UUID válido: ${kahoot.themeId}');
      }

      final Map<String, dynamic> kahootData = KahootMapper.toMap(kahoot);

      // =================== DEBUG DETALLADO ===================
      print('\n=== 🚀 DEBUG: Datos a enviar al guardar Kahoot (corregido) ===');
      
      // Mostrar JSON formateado
      final jsonString = json.encode(kahootData);
      final formattedJson = JsonEncoder.withIndent('  ').convert(kahootData);
      print('📦 JSON COMPLETO (corregido):');
      print(formattedJson);

      // Verificar campos específicos
      print('\n🔍 VERIFICACIÓN DE CAMPOS:');
      print('  - title (camelCase): ${kahootData['title']}');
      print('  - themeId (camelCase): ${kahootData['themeId']}');
      print('  - visibility (camelCase): ${kahootData['visibility']}');
      print('  - status (camelCase): ${kahootData['status']}');
      print('  - questions (camelCase): ${(kahootData['questions'] as List?)?.length ?? 0} preguntas');

      // Verificar primera pregunta
      if (kahootData['questions'] != null && (kahootData['questions'] as List).isNotEmpty) {
        final firstQuestion = (kahootData['questions'] as List).first as Map<String, dynamic>;
        print('   Primera pregunta campos: ${firstQuestion.keys.join(', ')}');
        print('   - text (camelCase): ${firstQuestion['text']}');
        print('   - timeLimit (camelCase): ${firstQuestion['timeLimit']} (tipo: ${firstQuestion['timeLimit']?.runtimeType})');
        print('   - type (camelCase): ${firstQuestion['type']} (debe ser: single, multiple o true_false)');
        print('   - points (camelCase): ${firstQuestion['points']} (tipo: ${firstQuestion['points']?.runtimeType})');
        
        // Verificar que el tipo sea válido
        final validTypes = ['single', 'multiple', 'true_false'];
        if (!validTypes.contains(firstQuestion['type'])) {
          print('   ⚠️ ADVERTENCIA: Tipo de pregunta inválido: ${firstQuestion['type']}');
          print('   Debe ser uno de: ${validTypes.join(', ')}');
        }
      }
      print('===================================================\n');
      // =================== FIN DEBUG ===================

      // Remover campos que NO se deben enviar
      kahootData.remove('authorId');
      kahootData.remove('createdAt');
      kahootData.remove('playCount');

      final headers = await _getHeaders();

      // Si el kahoot tiene id, es una actualización (PUT)
      if (kahoot.id != null && kahoot.id!.isNotEmpty) {
        print('🔄 Actualizando Kahoot existente (PUT)');
        final response = await http.put(
          Uri.parse('$baseUrl/kahoots/${kahoot.id}'),
          headers: headers,
          body: jsonString,
        );

        _logResponse(response, 'PUT');

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = json.decode(response.body);
          return KahootMapper.fromMap(responseData);
        } else {
          throw Exception('Error al actualizar kahoot: ${response.statusCode} - ${response.body}');
        }
      } else {
        // En creación, no se envía el id
        kahootData.remove('id');
        print('🆕 Creando nuevo Kahoot (POST)');
        final response = await http.post(
          Uri.parse('$baseUrl/kahoots'),
          headers: headers,
          body: jsonString,
        );

        _logResponse(response, 'POST');

        if (response.statusCode == 201) {
          final Map<String, dynamic> responseData = json.decode(response.body);
          return KahootMapper.fromMap(responseData);
        } else {
          throw Exception('Error al guardar kahoot: ${response.statusCode} - ${response.body}');
        }
      }
    } catch (e) {
      print('❌ Error en saveKahoot: $e');
      rethrow;
    }
  }

  void _logResponse(http.Response response, String method) {
    print('\n=== 📥 DEBUG: Respuesta del servidor ($method) ===');
    print('📊 Status Code: ${response.statusCode}');
    print('📦 Body: ${response.body}');
    
    if (response.statusCode != 200 && response.statusCode != 201) {
      try {
        final errorJson = json.decode(response.body);
        if (errorJson is Map<String, dynamic>) {
          print('🔍 Error detallado:');
          print('  - Mensaje: ${errorJson['message']}');
          print('  - Código: ${errorJson['code']}');
          
          // Mostrar sugerencias basadas en el error
          if (response.statusCode == 400) {
            print('💡 SUGERENCIAS:');
            print('   1. Verificar que timeLimit esté en camelCase');
            print('   2. Verificar que timeLimit sea un número entero positivo');
            print('   3. Verificar que themeId sea un UUID válido');
            print('   4. Verificar que el tipo de pregunta sea: single, multiple o true_false');
            print('   5. Para preguntas quiz: single=1 respuesta correcta, multiple=2+ respuestas correctas');
          }
        }
      } catch (e) {
        print('No se pudo parsear el error: $e');
      }
    }
    print('==============================================\n');
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
