import 'package:kahoot_project/features/kahoot/domain/entities/question.dart';
import 'package:kahoot_project/features/kahoot/infrastructure/repositories/mappers/answer_mapper.dart';

class QuestionMapper {
  // Convierte un Map (JSON) a una entidad Question
  static Question fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'],
      text: map['text'] ?? '',
      mediaId: map['mediaId'],
      timeLimitSeconds: map['timeLimitSeconds'] ?? 20,
      type: _stringToQuestionType(map['type']),
      answers: List<Map<String, dynamic>>.from(map['answers'] ?? [])
          .map(AnswerMapper.fromMap)
          .toList(),
    );
  }

  // Convierte una entidad Question a un Map (JSON)
  static Map<String, dynamic> toMap(Question question) {
    return {
      if (question.id != null) 'id': question.id,
      'text': question.text,
      if (question.mediaId != null) 'mediaId': question.mediaId,
      'timeLimitSeconds': question.timeLimitSeconds,
      'type': _questionTypeToString(question.type),
      'answers': question.answers.map(AnswerMapper.toMap).toList(),
    };
  }

  // Helper para convertir string a enum
  static QuestionType _stringToQuestionType(String type) {
    switch (type) {
      case 'trueFalse':
        return QuestionType.trueFalse;
      case 'quiz':
      default:
        return QuestionType.quiz;
    }
  }

  // Helper para convertir enum a string
  static String _questionTypeToString(QuestionType type) {
    switch (type) {
      case QuestionType.trueFalse:
        return 'trueFalse';
      case QuestionType.quiz:
      default:
        return 'quiz';
    }
  }
}