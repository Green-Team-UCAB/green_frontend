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

      // Validar que el puntaje sea positivo
      if (question.points <= 0) {
        return 'La pregunta ${i + 1} debe tener un puntaje positivo mayor a 0';
      }

      // Validar que el tiempo límite sea positivo
      if (question.timeLimit <= 0) {
        return 'La pregunta ${i + 1} debe tener un tiempo límite positivo mayor a 0';
      }

      if (question.answers.isEmpty) {
        return 'La pregunta ${i + 1} debe tener al menos una respuesta';
      }

      // 🔴 NUEVA VALIDACIÓN: Verificar respuestas individualmente
      for (var j = 0; j < question.answers.length; j++) {
        final answer = question.answers[j];
        final hasText = answer.text != null && answer.text!.isNotEmpty;
        final hasMedia = answer.mediaId != null && answer.mediaId!.isNotEmpty;
        
        if (!hasText && !hasMedia) {
          return 'La respuesta ${j + 1} de la pregunta ${i + 1} debe tener texto o imagen';
        }
        
        if (hasText && hasMedia) {
          return 'La respuesta ${j + 1} de la pregunta ${i + 1} no puede tener texto e imagen simultáneamente. Elige solo uno.';
        }
      }

      // Validación de respuestas correctas para preguntas de quiz
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