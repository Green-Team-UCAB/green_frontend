import 'package:flutter/material.dart';
import 'package:green_frontend/features/kahoot/application/use_cases/save_kahoot_use_case.dart';
import 'package:green_frontend/features/kahoot/domain/entities/kahoot.dart';
import 'package:green_frontend/features/kahoot/domain/entities/question.dart';
import 'package:green_frontend/features/kahoot/domain/entities/answer.dart';
import 'package:green_frontend/core/network/ai_service.dart';
import 'package:green_frontend/features/kahoot/domain/repositories/ikahoot_repository.dart';
import 'package:green_frontend/injection_container.dart';

class KahootProvider with ChangeNotifier {
  Kahoot _currentKahoot = Kahoot.empty();
  bool _isLoading = false;
  String? _error;
  final SaveKahootUseCase _saveKahootUseCase;
  final KahootRepository _kahootRepository;
  bool _isGeneratingAi = false;
  bool get isGeneratingAi => _isGeneratingAi;

  KahootProvider(this._saveKahootUseCase, this._kahootRepository);

  Kahoot get currentKahoot => _currentKahoot;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setTitle(String title) {
    _currentKahoot = _currentKahoot.copyWith(title: title);
    notifyListeners();
  }

  void setDescription(String description) {
    _currentKahoot = _currentKahoot.copyWith(description: description);
    notifyListeners();
  }

  void setVisibility(String visibility) {
    _currentKahoot = _currentKahoot.copyWith(visibility: visibility);
    notifyListeners();
  }

  void setThemeId(String themeId) {
    _currentKahoot = _currentKahoot.copyWith(themeId: themeId);
    notifyListeners();
  }

  void setCategory(String category) {
    _currentKahoot = _currentKahoot.copyWith(category: category);
    notifyListeners();
  }

  void setCoverImageId(String? coverImageId) {
    _currentKahoot = _currentKahoot.copyWith(coverImageId: coverImageId);
    notifyListeners();
  }

  void addQuestion(Question question) {
    final updatedQuestions = List<Question>.from(_currentKahoot.questions)
      ..add(question);
    _currentKahoot = _currentKahoot.copyWith(questions: updatedQuestions);
    notifyListeners();
  }

  void removeQuestion(int index) {
    final updatedQuestions = List<Question>.from(_currentKahoot.questions)
      ..removeAt(index);
    _currentKahoot = _currentKahoot.copyWith(questions: updatedQuestions);
    notifyListeners();
  }

  void updateQuestion(int index, Question question) {
    final updatedQuestions = List<Question>.from(_currentKahoot.questions);
    updatedQuestions[index] = question;
    _currentKahoot = _currentKahoot.copyWith(questions: updatedQuestions);
    notifyListeners();
  }

  void duplicateQuestion(int index) {
    if (index < 0 || index >= _currentKahoot.questions.length) return;
    
    final questionToDuplicate = _currentKahoot.questions[index];
    final duplicatedQuestion = questionToDuplicate.duplicate();
    
    final updatedQuestions = List<Question>.from(_currentKahoot.questions);
    updatedQuestions.insert(index + 1, duplicatedQuestion);
    
    _currentKahoot = _currentKahoot.copyWith(questions: updatedQuestions);
    notifyListeners();
  }

  void changeQuestionPoints(int index, int newPoints) {
    if (index < 0 || index >= _currentKahoot.questions.length) return;
    
    if (newPoints <= 0) {
      _error = 'La puntuación debe ser mayor a 0';
      notifyListeners();
      return;
    }
    
    final question = _currentKahoot.questions[index];
    final updatedQuestion = question.copyWith(points: newPoints);
    
    updateQuestion(index, updatedQuestion);
  }

  void reorderQuestions(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    
    final updatedQuestions = List<Question>.from(_currentKahoot.questions);
    final question = updatedQuestions.removeAt(oldIndex);
    updatedQuestions.insert(newIndex, question);
    
    _currentKahoot = _currentKahoot.copyWith(questions: updatedQuestions);
    notifyListeners();
  }

  Future<void> generateWithAi(String topic) async {
    _isGeneratingAi = true;
    _error = null;
    notifyListeners();

    try {
      final aiService = sl<AiService>();
      final data = await aiService.generateFullQuiz(topic);

      if (data != null) {
        _currentKahoot = _currentKahoot.copyWith(
          title: data['title'] ?? 'Quiz IA',
          description: data['description'] ?? '',
        );

        final List<dynamic> questionsJson = data['questions'];
        final List<Question> newQuestions = [];

        for (var q in questionsJson) {
          final String qId =
              DateTime.now().millisecondsSinceEpoch.toString() +
              q['text'].hashCode.toString();

          final List<Answer> answers = (q['answers'] as List).map((a) {
            return Answer(
              id: qId + a['text'].hashCode.toString(),
              text: a['text'],
              isCorrect: a['isCorrect'],
            );
          }).toList();

          newQuestions.add(
            Question(
              id: qId,
              text: q['text'],
              type: (q['type'] == 'trueFalse')
                  ? QuestionType.trueFalse
                  : QuestionType.quiz,
              timeLimit: q['timeLimit'] ?? 20,
              points: q['points'] ?? 1000,
              answers: answers,
              mediaId: null,
            ),
          );
        }

        _currentKahoot = _currentKahoot.copyWith(questions: newQuestions);
      } else {
        _error = "La IA no pudo generar el quiz. Intenta otro tema.";
      }
    } catch (e) {
      _error = "Error conectando con IA: $e";
    } finally {
      _isGeneratingAi = false;
      notifyListeners();
    }
  }

  Future<void> saveKahoot() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_currentKahoot.themeId.isEmpty) {
        throw Exception('Debe seleccionar un tema para el Kahoot');
      }

      final savedKahoot = await _saveKahootUseCase.execute(_currentKahoot);
      _currentKahoot = savedKahoot;
    } catch (e) {
      _error = 'Error al guardar el Kahoot: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _currentKahoot = Kahoot.empty();
    _error = null;
    notifyListeners();
  }

  void loadKahoot(Kahoot kahoot) {
    _currentKahoot = kahoot;
    notifyListeners();
  }

  String? validate() {
    if (_currentKahoot.title.isEmpty) {
      return 'El título es requerido';
    }
    
    if (_currentKahoot.themeId.isEmpty) {
      return 'Debe seleccionar un tema';
    }
    
    if (_currentKahoot.questions.isEmpty) {
      return 'Debe agregar al menos una pregunta';
    }
    
    for (var i = 0; i < _currentKahoot.questions.length; i++) {
      final question = _currentKahoot.questions[i];
      if (!question.isValid()) {
        return 'La pregunta ${i + 1} no es válida';
      }
    }
    
    return null;
  }

  Future<void> loadFullKahoot(String kahootId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Usar el método getKahootById directamente de la interfaz
      final fullKahoot = await _kahootRepository.getKahootById(kahootId);
      _currentKahoot = fullKahoot;
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar el kahoot: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}