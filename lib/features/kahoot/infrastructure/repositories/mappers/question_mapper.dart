import 'package:green_frontend/features/kahoot/domain/entities/question.dart';
import 'package:green_frontend/features/kahoot/infrastructure/repositories/mappers/answer_mapper.dart';

class QuestionMapper {
  // Convierte un Map (en JSON) a una entidad Question
  static Question fromMap(Map<String, dynamic> map) {
    // Leer en ambos formatos: timeLimit en camelCase
    int timeLimit = _parsePositiveInt(
      map['timeLimit'] ?? 20,
      20,
      'timeLimit'
    );

    int points = _parsePositiveInt(map['points'] ?? 1000, 1000, 'points');

    return Question(
      id: map['id'],
      text: map['text'] ?? map['questionText'] ?? '',
      mediaId: map['mediaId'] ?? map['slideImageURL'],
      timeLimit: timeLimit,
      type: _stringToQuestionType(map['type'] ?? 'single'), // Cambiado: 'single' por defecto
      answers: List<Map<String, dynamic>>.from(map['answers'] ?? [])
          .map(AnswerMapper.fromMap)
          .toList(),
      points: points,
    );
  }

  // Convierte una entidad Question a un Map (a JSON)
  static Map<String, dynamic> toMap(Question question) {
    final int timeLimit = _ensurePositiveInt(question.timeLimit, 20);
    final int points = _ensurePositiveInt(question.points, 1000);
    
    // Determinar el tipo basado en QuestionType y respuestas
    String typeString = _questionTypeToBackendString(question);

    print('🔄 QuestionMapper.toMap (corregido):');
    print('   - timeLimit (camelCase): $timeLimit');
    print('   - points (camelCase): $points');
    print('   - type (backend): $typeString');

    return {
      if (question.id != null && question.id!.isNotEmpty) 'id': question.id,
      'text': question.text,
      if (question.mediaId != null && question.mediaId!.isNotEmpty)
        'mediaId': question.mediaId,
      'timeLimit': timeLimit,
      'type': typeString, // Usar el tipo convertido para backend
      'answers': question.answers.map(AnswerMapper.toMap).toList(),
      'points': points,
    };
  }

  // Convertir nuestro QuestionType a string del backend
  static String _questionTypeToBackendString(Question question) {
    switch (question.type) {
      case QuestionType.trueFalse:
        return 'true_false';
      case QuestionType.quiz:
        // Para quiz, determinar si es single o multiple basado en respuestas correctas
        int correctAnswersCount = question.answers.where((a) => a.isCorrect).length;
        return correctAnswersCount == 1 ? 'single' : 'multiple';
      default:
        return 'single'; // Por defecto
    }
  }

  // Convertir string del backend a nuestro QuestionType
  static QuestionType _stringToQuestionType(String type) {
    switch (type.toLowerCase()) {
      case 'true_false':
        return QuestionType.trueFalse;
      case 'multiple':
      case 'single':
        return QuestionType.quiz; // Ambos son quiz en nuestro modelo
      default:
        return QuestionType.quiz; // Por defecto
    }
  }

  // Convertir nuestro QuestionType a string (para uso interno)
  static String _questionTypeToString(QuestionType type) {
    switch (type) {
      case QuestionType.trueFalse:
        return 'trueFalse';
      case QuestionType.quiz:
        return 'quiz';
      default:
        return 'quiz';
    }
  }

  static int _parsePositiveInt(dynamic value, int defaultValue, String fieldName) {
    if (value == null) return defaultValue;
    try {
      if (value is int) {
        return value > 0 ? value : defaultValue;
      } else if (value is String) {
        final parsed = int.tryParse(value);
        return (parsed != null && parsed > 0) ? parsed : defaultValue;
      } else if (value is double) {
        final intVal = value.toInt();
        return intVal > 0 ? intVal : defaultValue;
      }
    } catch (e) {
      print('⚠️ Error parseando $fieldName: $e');
    }
    return defaultValue;
  }

  static int _ensurePositiveInt(int value, int defaultValue) {
    if (value <= 0) {
      print('⚠️ Valor no positivo: $value. Usando valor por defecto: $defaultValue');
      return defaultValue;
    }
    return value;
  }
}
