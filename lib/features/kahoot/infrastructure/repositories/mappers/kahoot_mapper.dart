import 'package:green_frontend/features/kahoot/domain/entities/kahoot.dart';
import 'package:green_frontend/features/kahoot/infrastructure/repositories/mappers/question_mapper.dart';

class KahootMapper {
  static Kahoot fromMap(Map<String, dynamic> map) {
    return Kahoot(
      id: map['id'],
      title: map['title'] ?? '',
      description: map['description'],
      coverImageId: map['coverImageId'],
      visibility: map['visibility'] ?? 'private',
      themeId: map['themeId'] ?? '',
      authorId: map['author'] != null ? map['author']['id'] : null,
      status: map['status'] ?? 'draft',
      questions: List<Map<String, dynamic>>.from(map['questions'] ?? [])
          .map(QuestionMapper.fromMap)
          .toList(),
      category: map['category'],
      playCount: map['playCount'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : null,
    );
  }

  static Map<String, dynamic> toMap(Kahoot kahoot) {
    // Validar que themeId sea un UUID válido
    final themeId = kahoot.themeId;
    if (themeId.isEmpty) {
      throw Exception('El themeId es requerido y debe ser un UUID válido');
    }

    // Validar UUID básico
    final uuidRegex = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$', caseSensitive: false);
    if (!uuidRegex.hasMatch(themeId)) {
      throw Exception('El themeId "$themeId" no es un UUID válido');
    }

    // Crear el map con las preguntas usando QuestionMapper (que ya maneja timeLimit)
    final Map<String, dynamic> result = {
      if (kahoot.id != null && kahoot.id!.isNotEmpty) 'id': kahoot.id,
      'title': kahoot.title,
      if (kahoot.description != null && kahoot.description!.isNotEmpty)
        'description': kahoot.description,
      if (kahoot.coverImageId != null && kahoot.coverImageId!.isNotEmpty)
        'coverImageId': kahoot.coverImageId,
      'visibility': kahoot.visibility,
      'themeId': themeId, // camelCase, validado como UUID
      'status': kahoot.status,
      'questions': kahoot.questions.map(QuestionMapper.toMap).toList(),
      if (kahoot.category != null && kahoot.category!.isNotEmpty)
        'category': kahoot.category,
    };

    // DEBUG: Verificar que las preguntas tienen timeLimit en camelCase
    print('🔍 KahootMapper.toMap - Verificando preguntas:');
    if (result['questions'] != null && (result['questions'] as List).isNotEmpty) {
      for (var i = 0; i < (result['questions'] as List).length; i++) {
        final question = (result['questions'] as List)[i] as Map<String, dynamic>;
        if (question.containsKey('timeLimit')) {
          print('   Pregunta $i: timeLimit = ${question['timeLimit']} (${question['timeLimit'].runtimeType})');
        } else if (question.containsKey('TimeLimitSeconds')) {
          print('   ⚠️ Pregunta $i: Tiene TimeLimitSeconds (incorrecto)');
        } else {
          print('   ⚠️ Pregunta $i: No tiene timeLimit');
        }
      }
    }

    return result;
  }
}
