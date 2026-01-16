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
      // 🔴 DEBUG DETALLADO del themeId
      print('🔴🔴🔴 [DEBUG TEMA] INICIO saveKahoot');
      print('   Kahoot ID: ${kahoot.id}');
      print('   Título: ${kahoot.title}');
      print('   ThemeId en la entidad Kahoot: "${kahoot.themeId}"');
      print('   Longitud: ${kahoot.themeId.length}');
      print('   Está vacío?: ${kahoot.themeId.isEmpty}');
      print('   Es null?: ${kahoot.themeId == null}');
      
      // Verificar si es un UUID válido
      final uuidRegex = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        caseSensitive: false,
      );
      final isUuidValid = uuidRegex.hasMatch(kahoot.themeId);
      print('   Es UUID válido?: $isUuidValid');
      
      if (!isUuidValid) {
        print('   ⚠️⚠️⚠️ ATENCIÓN: themeId NO es un UUID válido!');
        print('   Valor actual: "${kahoot.themeId}"');
      }

      // Validar el kahoot antes de convertirlo
      if (kahoot.themeId.isEmpty) {
        throw Exception('Debe seleccionar un tema para el Kahoot');
      }

      // Validar UUID del themeId
      if (!isUuidValid) {
        throw Exception(
          'El ID del tema no es un UUID válido: "${kahoot.themeId}"',
        );
      }

      final Map<String, dynamic> kahootData = KahootMapper.toMap(kahoot);

      // 🔴 DEBUG: Verificar qué está enviando el mapper
      print('🟢 [DEBUG TEMA] Después de KahootMapper.toMap:');
      print('   ¿Contiene themeId?: ${kahootData.containsKey("themeId")}');
      print('   Valor de themeId en kahootData: "${kahootData["themeId"]}"');
      print('   Todas las claves: ${kahootData.keys.toList()}');
      
      // Mostrar todo el objeto JSON
      print('   JSON completo:');
      final jsonIndented = JsonEncoder.withIndent('  ').convert(kahootData);
      print(jsonIndented);

      // Remover campos que NO se deben enviar
      kahootData.remove('authorId');
      kahootData.remove('createdAt');
      kahootData.remove('playCount');

      final headers = await _getHeaders();
      
      // 🔴 DEBUG: Imprimir token y headers
      final token = await TokenStorage.getToken();
      print('🔵 [DEBUG saveKahoot] Token: ${token != null ? "Presente (${token.length} chars)" : "NULO"}');
      print('   Headers: $headers');

      // Si el kahoot tiene id, es una actualización (PUT)
      if (kahoot.id != null && kahoot.id!.isNotEmpty) {
        // 🔴 CORRECCIÓN: Remover el id del cuerpo para PUT, ya que va en la URL
        final Map<String, dynamic> dataForPut = Map<String, dynamic>.from(kahootData);
        dataForPut.remove('id');
        
        // 🔴 DEBUG: Imprimir datos finales para PUT
        print('🟡 [DEBUG saveKahoot] Enviando PUT a: $baseUrl/kahoots/${kahoot.id}');
        print('   Datos sin "id" (para PUT): $dataForPut');
        print('   JSON a enviar: ${json.encode(dataForPut)}');
        
        final response = await http.put(
          Uri.parse('$baseUrl/kahoots/${kahoot.id}'),
          headers: headers,
          body: json.encode(dataForPut),
        );

        // 🔴 DEBUG: Imprimir respuesta del backend
        print('🔴 [DEBUG saveKahoot] Respuesta del servidor:');
        print('   Status Code: ${response.statusCode}');
        print('   Body: ${response.body}');
        print('   Headers: ${response.headers}');

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = json.decode(response.body);
          print('🟢 [DEBUG saveKahoot] Kahoot actualizado exitosamente');
          print('   ID devuelto: ${responseData['id']}');
          print('   ThemeId devuelto: ${responseData['themeId']}');
          return KahootMapper.fromMap(responseData);
        } else {
          print('🔴 [DEBUG saveKahoot] ERROR en PUT: ${response.statusCode} - ${response.body}');
          throw Exception(
            'Error al actualizar kahoot: ${response.statusCode} - ${response.body}',
          );
        }
      } else {
        // En creación, no se envía el id
        kahootData.remove('id');
        
        // 🔴 DEBUG: Imprimir datos finales para POST
        print('🟡 [DEBUG saveKahoot] Enviando POST a: $baseUrl/kahoots');
        print('   Datos (para POST): $kahootData');
        print('   JSON a enviar: ${json.encode(kahootData)}');
        
        final response = await http.post(
          Uri.parse('$baseUrl/kahoots'),
          headers: headers,
          body: json.encode(kahootData),
        );

        // 🔴 DEBUG: Imprimir respuesta del backend
        print('🔴 [DEBUG saveKahoot] Respuesta del servidor:');
        print('   Status Code: ${response.statusCode}');
        print('   Body: ${response.body}');

        if (response.statusCode == 201) {
          final Map<String, dynamic> responseData = json.decode(response.body);
          print('🟢 [DEBUG saveKahoot] Kahoot creado exitosamente');
          print('   ID devuelto: ${responseData['id']}');
          print('   ThemeId devuelto: ${responseData['themeId']}');
          
          // 🔴 IMPORTANTE: Verificar si el backend devuelve themeId
          if (responseData["themeId"] == null) {
            print('   ⚠️⚠️⚠️ ATENCIÓN: El backend NO devolvió themeId!');
            print('   Respuesta completa: $responseData');
            
            // 🔴 CORRECCIÓN: Si el backend no devuelve themeId, usar el que enviamos
            if (kahoot.themeId.isNotEmpty) {
              print('   ✅ Recuperando themeId del kahoot original...');
              responseData['themeId'] = kahoot.themeId;
            }
          }
          
          return KahootMapper.fromMap(responseData);
        } else {
          print('🔴 [DEBUG saveKahoot] ERROR en POST: ${response.statusCode} - ${response.body}');
          throw Exception(
            'Error al guardar kahoot: ${response.statusCode} - ${response.body}',
          );
        }
      }
    } catch (e) {
      print('🔴🔴🔴 [DEBUG saveKahoot] EXCEPCIÓN CAPTURADA: $e');
      print('   Stack trace: ${e.toString()}');
      rethrow;
    }
  }

  // ✅ NUEVO: Obtener un kahoot por ID para editar
  Future<Kahoot> getKahoot(String kahootId) async {
    try {
      final headers = await _getHeaders();
      
      // 🔴 DEBUG: Imprimir llamada GET
      print('🟡 [DEBUG getKahoot] Obteniendo kahoot ID: $kahootId');
      print('   URL: $baseUrl/kahoots/$kahootId');
      
      final response = await http.get(
        Uri.parse('$baseUrl/kahoots/$kahootId'),
        headers: headers,
      );

      // 🔴 DEBUG: Imprimir respuesta
      print('🔴 [DEBUG getKahoot] Respuesta del servidor:');
      print('   Status Code: ${response.statusCode}');
      
      // 🔴 CORRECCIÓN: Parsear y mostrar el JSON completo con indentación
      final Map<String, dynamic> responseData = json.decode(response.body);
      final jsonIndented = JsonEncoder.withIndent('  ').convert(responseData);
      print('   Body (formateado):\n$jsonIndented');

      if (response.statusCode == 200) {
        print('🟢 [DEBUG getKahoot] Kahoot obtenido exitosamente');
        print('   Título: ${responseData['title']}');
        print('   Theme (tipo): ${responseData['theme']?.runtimeType}');
        
        // 🔴 IMPORTANTE: Verificar estructura del theme
        if (responseData['theme'] is Map) {
          final themeMap = responseData['theme'] as Map<String, dynamic>;
          print('   Theme ID desde objeto: ${themeMap['id']}');
          print('   Theme Name desde objeto: ${themeMap['name']}');
        }
        
        print('   Número de preguntas: ${responseData['questions'] != null ? (responseData['questions'] as List).length : 0}');
        
        // 🔴 ADVERTENCIA si no hay preguntas
        if (responseData['questions'] == null || (responseData['questions'] as List).isEmpty) {
          print('⚠️⚠️⚠️ [ADVERTENCIA] El backend no devolvió preguntas para este kahoot');
          print('   Posible solución: Verificar si el endpoint /kahoots/{id} incluye preguntas o usar otro endpoint');
        }
        
        return KahootMapper.fromMap(responseData);
      } else if (response.statusCode == 404) {
        print('🔴 [DEBUG getKahoot] Kahoot no encontrado');
        throw Exception('Kahoot no encontrado: ${response.statusCode}');
      } else {
        print('🔴 [DEBUG getKahoot] Error al obtener kahoot');
        throw Exception('Error al obtener kahoot: ${response.statusCode}');
      }
    } catch (e) {
      print('🔴🔴🔴 [DEBUG getKahoot] EXCEPCIÓN CAPTURADA: $e');
      print('   Stack trace: ${e.toString()}');
      rethrow;
    }
  }

  // ✅ NUEVO: Obtener un kahoot CON preguntas (endpoint específico si existe)
  Future<Kahoot> getKahootWithQuestions(String kahootId) async {
    try {
      final headers = await _getHeaders();
      
      // 🔴 POSIBLE ENDPOINT ALTERNATIVO: Ajustar según la API real
      print('🟡 [DEBUG getKahootWithQuestions] Obteniendo kahoot con preguntas ID: $kahootId');
      print('   URL: $baseUrl/kahoots/$kahootId?include=questions');
      
      final response = await http.get(
        Uri.parse('$baseUrl/kahoots/$kahootId?include=questions'),
        headers: headers,
      );

      print('🔴 [DEBUG getKahootWithQuestions] Respuesta del servidor:');
      print('   Status Code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print('🟢 [DEBUG getKahootWithQuestions] Kahoot con preguntas obtenido exitosamente');
        print('   Número de preguntas: ${responseData['questions'] != null ? (responseData['questions'] as List).length : 0}');
        
        return KahootMapper.fromMap(responseData);
      } else {
        print('🔴 [DEBUG getKahootWithQuestions] Falló, usando endpoint estándar...');
        // Si falla, intentar con el endpoint estándar
        return await getKahoot(kahootId);
      }
    } catch (e) {
      print('🔴 [DEBUG getKahootWithQuestions] Error: $e, usando endpoint estándar...');
      return await getKahoot(kahootId);
    }
  }

  // ✅ NUEVO: Actualizar un kahoot específico
  Future<Kahoot> updateKahoot(Kahoot kahoot) async {
    print('🟡 [DEBUG updateKahoot] Llamando a updateKahoot');
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
      // Primero obtenemos el kahoot original
      final originalKahoot = await getKahoot(kahootId);
      
      // Creamos una copia con nuevo ID
      final duplicatedKahoot = originalKahoot.copyWith(
        id: null,
        title: '${originalKahoot.title} (Copia)',
        playCount: 0,
        createdAt: null,
      );
      
      // Guardamos la copia
      return await saveKahoot(duplicatedKahoot);
    } catch (e) {
      throw Exception('Error al duplicar kahoot: $e');
    }
  }
}