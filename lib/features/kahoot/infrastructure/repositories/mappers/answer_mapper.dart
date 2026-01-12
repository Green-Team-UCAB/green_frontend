import 'package:green_frontend/features/kahoot/domain/entities/answer.dart';

class AnswerMapper {
  // Convierte un Map (en JSON) a una entidad Answer
  static Answer fromMap(Map<String, dynamic> map) {
    return Answer(
      id: map['id'] ?? map['index']?.toString(),
      text: map['text'],
      mediaId: map['mediaId'] ?? map['mediaURL'],
      isCorrect: map['isCorrect'] ?? false,
    );
  }

  // Convierte una entidad Answer a un Map (a JSON) - USANDO CAMEL CASE
  static Map<String, dynamic> toMap(Answer answer) {
    return {
      'isCorrect': answer.isCorrect,
      if (answer.text != null && answer.text!.isNotEmpty) 'text': answer.text,
      if (answer.mediaId != null && answer.mediaId!.isNotEmpty)
        'mediaId': answer.mediaId,
    };
  }
}
