import 'package:green_frontend/features/kahoot/domain/entities/kahoot.dart';
import 'package:green_frontend/features/kahoot/infrastructure/repositories/mappers/question_mapper.dart';

class KahootMapper {
  static Kahoot fromMap(Map<String, dynamic> map) {
    print('🔴 [DEBUG KahootMapper.fromMap] Mapeando desde JSON:');
    print('   Todas las claves disponibles: ${map.keys.toList()}');
    print('   ID recibido: ${map['id']}');
    print('   Título: ${map['title']}');
    print('   ThemeId (camelCase): ${map['themeId']}');
    print('   theme_id (snake_case): ${map['theme_id']}');
    print('   theme (sin id): ${map['theme']}');
    
    // 🔴 CORRECCIÓN CRÍTICA: Extraer el themeId del objeto theme si es un mapa
    String extractedThemeId = '';
    
    if (map['themeId'] is String && (map['themeId'] as String).isNotEmpty) {
      extractedThemeId = map['themeId'];
    } else if (map['theme_id'] is String && (map['theme_id'] as String).isNotEmpty) {
      extractedThemeId = map['theme_id'];
    } else if (map['theme'] != null) {
      if (map['theme'] is Map) {
        final themeMap = map['theme'] as Map<String, dynamic>;
        extractedThemeId = themeMap['id']?.toString() ?? '';
        print('   🔵 [DEBUG] ThemeId extraído del objeto theme: $extractedThemeId');
      } else if (map['theme'] is String) {
        extractedThemeId = map['theme'];
      }
    }
    
    // 🔴 CORRECCIÓN: Verificar si hay preguntas en la respuesta
    List<dynamic> questionsList = map['questions'] ?? [];
    print('   🔵 [DEBUG] Número de preguntas en response: ${questionsList.length}');
    
    // Si no hay preguntas, intentar obtenerlas de otro campo o usar lista vacía
    if (questionsList.isEmpty) {
      print('   ⚠️⚠️⚠️ [ADVERTENCIA] No se encontraron preguntas en la respuesta del backend');
      print('   Todos los campos disponibles:');
      map.forEach((key, value) {
        if (key.toString().toLowerCase().contains('question')) {
          print('     $key: $value');
        }
      });
    }
    
    return Kahoot(
      id: map['id'],
      title: map['title'] ?? '',
      description: map['description'],
      coverImageId: map['coverImageId'],
      visibility: map['visibility'] ?? 'private',
      // 🔴 CORRECCIÓN: Usar el themeId extraído
      themeId: extractedThemeId,
      authorId: map['author'] != null ? map['author']['id'] : null,
      status: map['status'] ?? 'draft',
      // 🔴 CORRECCIÓN: Mapear preguntas (puede estar vacío si el backend no las envía)
      questions: List<Map<String, dynamic>>.from(questionsList)
          .map(QuestionMapper.fromMap)
          .toList(),
      category: map['category'],
      playCount: map['playCount'],
      createdAt:
          map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
    );
  }

  static Map<String, dynamic> toMap(Kahoot kahoot) {
    // Validar que themeId sea un UUID válido
    final themeId = kahoot.themeId;
    
    print('🔴 [DEBUG KahootMapper.toMap] Iniciando mapeo:');
    print('   themeId recibido: "$themeId"');
    print('   Longitud: ${themeId.length}');
    
    if (themeId.isEmpty) {
      throw Exception('El themeId es requerido y debe ser un UUID válido');
    }

    // Validar UUID básico
    final uuidRegex = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        caseSensitive: false);
    
    final isUuidValid = uuidRegex.hasMatch(themeId);
    print('   Es UUID válido?: $isUuidValid');
    
    if (!isUuidValid) {
      throw Exception('El themeId "$themeId" no es un UUID válido');
    }

    // 🔴 CORRECCIÓN: Asegurar que themeId esté en camelCase exacto
    final Map<String, dynamic> result = {
      if (kahoot.id != null && kahoot.id!.isNotEmpty) 'id': kahoot.id,
      'title': kahoot.title,
      if (kahoot.description != null && kahoot.description!.isNotEmpty)
        'description': kahoot.description,
      if (kahoot.coverImageId != null && kahoot.coverImageId!.isNotEmpty)
        'coverImageId': kahoot.coverImageId,
      'visibility': kahoot.visibility,
      'themeId': themeId, // camelCase exacto - IMPORTANTE
      'status': kahoot.status,
      'questions': kahoot.questions.map(QuestionMapper.toMap).toList(),
      if (kahoot.category != null && kahoot.category!.isNotEmpty)
        'category': kahoot.category,
    };

    print('🟢 [DEBUG KahootMapper.toMap] Resultado del mapeo:');
    print('   ¿Contiene "themeId"?: ${result.containsKey("themeId")}');
    print('   Valor de "themeId": "${result["themeId"]}"');
    print('   Tipo de "themeId": ${result["themeId"].runtimeType}');

    return result;
  }
}