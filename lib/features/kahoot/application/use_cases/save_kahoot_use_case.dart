import 'package:green_frontend/features/kahoot/domain/entities/kahoot.dart';
import 'package:green_frontend/features/kahoot/domain/repositories/ikahoot_repository.dart';

import 'kahoot_validator.dart';

class SaveKahootUseCase {
  final KahootRepository repository;

  SaveKahootUseCase(this.repository);

  Future<Kahoot> execute(Kahoot kahoot) async {
    final titleError = KahootValidator.validateTitle(kahoot.title);
    if (titleError != null) {
      throw Exception(titleError);
    }
    
    final questionsError = KahootValidator.validateQuestions(kahoot.questions);
    if (questionsError != null) {
      throw Exception(questionsError);
    }
    
    return await repository.saveKahoot(kahoot);
  }
}

