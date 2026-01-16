import 'package:green_frontend/features/kahoot/domain/entities/answer.dart';

enum QuestionType { quiz, trueFalse }

class Question {
  String? id;
  String text;
  String? mediaId;
  int timeLimit; // CAMBIADO: timeLimitSeconds → timeLimit
  QuestionType type;
  List<Answer> answers;
  int points;

  Question({
    this.id,
    required this.text,
    this.mediaId,
    required this.timeLimit, // CAMBIADO
    required this.type,
    required this.answers,
    required this.points,
  });

  // ✅ NUEVO: Método copyWith para facilitar actualizaciones
  Question copyWith({
    String? id,
    String? text,
    String? mediaId,
    int? timeLimit,
    QuestionType? type,
    List<Answer>? answers,
    int? points,
  }) {
    return Question(
      id: id ?? this.id,
      text: text ?? this.text,
      mediaId: mediaId ?? this.mediaId,
      timeLimit: timeLimit ?? this.timeLimit,
      type: type ?? this.type,
      answers: answers ?? this.answers,
      points: points ?? this.points,
    );
  }

  // ✅ NUEVO: Método para duplicar la pregunta
  Question duplicate() {
    return Question(
      id: null, // Nuevo ID se generará al guardar
      text: text,
      mediaId: mediaId,
      timeLimit: timeLimit,
      type: type,
      answers: answers.map((answer) => answer.copyWith(id: null)).toList(),
      points: points,
    );
  }

  // ✅ NUEVO: Método para verificar si la pregunta es válida
  bool isValid() {
    return text.isNotEmpty && 
           points > 0 && 
           timeLimit > 0 && 
           answers.isNotEmpty &&
           answers.any((answer) => answer.isCorrect);
  }
}