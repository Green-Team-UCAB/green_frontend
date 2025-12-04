import 'package:kahoot_project/features/kahoot/domain/entities/answer.dart';

enum QuestionType { quiz, trueFalse }

class Question {
  String? id;
  String text;
  String? mediaId;
  int timeLimitSeconds;
  QuestionType type;
  List<Answer> answers;
  int points; // Nuevo campo para el puntaje

  Question({
    this.id,
    required this.text,
    this.mediaId,
    required this.timeLimitSeconds,
    required this.type,
    required this.answers,
    required this.points, // Agregado
  });
}