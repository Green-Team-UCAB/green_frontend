import 'package:green_frontend/features/kahoot/domain/entities/question.dart';


class KahootValidator {
  static String? validateTitle(String title) {
    if (title.isEmpty) return 'El título es requerido';
    if (title.length < 3) return 'El título debe tener al menos 3 caracteres';
    if (title.length > 100) return 'El título no puede exceder 100 caracteres';
    return null;
  }

  static String? validateQuestions(List<Question> questions) {
    if (questions.isEmpty) return 'Debe agregar al menos una pregunta';
    
    for (var i = 0; i < questions.length; i++) {
      final question = questions[i];
      if (question.text.isEmpty) {
        return 'La pregunta ${i + 1} no puede estar vacía';
      }
      
      if (question.answers.isEmpty) {
        return 'La pregunta ${i + 1} debe tener al menos una respuesta';
      }
      
      if (question.type == QuestionType.quiz) {
        final correctAnswers = question.answers.where((a) => a.isCorrect).length;
        if (correctAnswers == 0) {
          return 'La pregunta ${i + 1} debe tener al menos una respuesta correcta';
        }
      }
    }
    
    return null;
  }
}