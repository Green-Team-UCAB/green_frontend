import 'package:kahoot_project/features/kahoot/domain/entities/answer.dart';

class AnswerMapper {
  // Convierte un Map (JSON) a una entidad Answer
  static Answer fromMap(Map<String, dynamic> map) {
    return Answer(
      id: map['id'],
      text: map['text'],
      mediaId: map['mediaId'],
      isCorrect: map['isCorrect'] ?? false,
    );
  }

  // Convierte una entidad Answer a un Map (JSON)
  static Map<String, dynamic> toMap(Answer answer) {
    return {
      if (answer.id != null) 'id': answer.id,
      if (answer.text != null) 'text': answer.text,
      if (answer.mediaId != null) 'mediaId': answer.mediaId,
      'isCorrect': answer.isCorrect,
    };
  }
}