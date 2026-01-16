import 'package:green_frontend/features/kahoot/domain/entities/kahoot.dart';
import 'package:green_frontend/features/kahoot/domain/repositories/ikahoot_repository.dart';
import 'kahoot_validator.dart';

class SaveKahootUseCase {
  final KahootRepository repository;

  SaveKahootUseCase(this.repository);

  Future<Kahoot> execute(Kahoot kahoot) async {
    try {
      // Validar título
      final titleError = KahootValidator.validateTitle(kahoot.title);
      if (titleError != null) {
        throw Exception(titleError);
      }
      
      // Validar preguntas (incluye la nueva validación de respuestas)
      final questionsError = KahootValidator.validateQuestions(kahoot.questions);
      if (questionsError != null) {
        throw Exception(questionsError);
      }
      
      // Validar que el tema esté seleccionado
      if (kahoot.themeId.isEmpty) {
        throw Exception('Debe seleccionar un tema para el Kahoot');
      }
      
      // 🔴 NUEVA VALIDACIÓN: Verificar que todas las respuestas sean válidas para el backend
      for (var question in kahoot.questions) {
        for (var answer in question.answers) {
          final hasText = answer.text != null && answer.text!.isNotEmpty;
          final hasMedia = answer.mediaId != null && answer.mediaId!.isNotEmpty;
          
          if (hasText && hasMedia) {
            throw Exception('Una respuesta contiene texto e imagen simultáneamente. Revisa las respuestas.');
          }
        }
      }
      
      return await repository.saveKahoot(kahoot);
    } catch (e) {
      rethrow;
    }
  }
}