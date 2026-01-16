import 'package:green_frontend/features/kahoot/domain/entities/kahoot.dart';
import 'package:green_frontend/features/kahoot/infrastructure/repositories/mappers/question_mapper.dart';

class KahootMapper {
  static Kahoot fromMap(Map<String, dynamic> map) {
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
      } else if (map['theme'] is String) {
        extractedThemeId = map['theme'];
      }
    }
    
    List<dynamic> questionsList = map['questions'] ?? [];
    
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
    final themeId = kahoot.themeId;
    
    if (themeId.isEmpty) {
      throw Exception('El themeId es requerido y debe ser un UUID válido');
    }

    final uuidRegex = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        caseSensitive: false);
    
    final isUuidValid = uuidRegex.hasMatch(themeId);
    
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

    return result;
  }
}
