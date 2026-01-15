import 'package:green_frontend/features/kahoot/domain/entities/answer.dart';

class AnswerMapper {
  // Convierte un Map (en JSON) a una entidad Answer
  static Answer fromMap(Map<String, dynamic> map) {
    return Answer(
      id: map['id'] ?? map['index']?.toString(),
      text: map['text'],
      mediaId: map['mediaId'] ?? map['mediaURL'],
      localMediaPath: map['localMediaPath'],
      isCorrect: map['isCorrect'] ?? false,
    );
  }

  // Convierte una entidad Answer a un Map (a JSON) - USANDO CAMEL CASE
  static Map<String, dynamic> toMap(Answer answer) {
    final Map<String, dynamic> map = {
      'isCorrect': answer.isCorrect,
    };

    // 🔴 SOLUCIÓN AL ERROR: Solo enviar text O mediaId, no ambos
    if (answer.mediaId != null && answer.mediaId!.isNotEmpty) {
      // Si hay imagen, enviar solo mediaId
      map['mediaId'] = answer.mediaId;
      // 🔴 NO enviar text si hay mediaId
    } else if (answer.text != null && answer.text!.isNotEmpty) {
      // Solo enviar text si NO hay mediaId
      map['text'] = answer.text;
    } else {
      // Si no hay ni text ni mediaId, enviar string vacío en text
      map['text'] = '';
    }

    return map;
  }
}