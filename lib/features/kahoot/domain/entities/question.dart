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
}
