import 'package:flutter/material.dart';
import 'package:green_frontend/features/kahoot/application/use_cases/save_kahoot_use_case.dart';
import 'package:green_frontend/features/kahoot/domain/entities/kahoot.dart';
import 'package:green_frontend/features/kahoot/domain/entities/question.dart';
// ✅ NUEVOS IMPORTS NECESARIOS
import 'package:green_frontend/features/kahoot/domain/entities/answer.dart';
import 'package:green_frontend/core/network/ai_service.dart';
import 'package:green_frontend/injection_container.dart'; // Para obtener sl<AiService>()

class KahootProvider with ChangeNotifier {
  Kahoot _currentKahoot = Kahoot.empty();
  bool _isLoading = false;
  String? _error;
  final SaveKahootUseCase _saveKahootUseCase;

  // ✅ VARIABLE PARA EL ESTADO DE CARGA DE IA
  bool _isGeneratingAi = false;
  bool get isGeneratingAi => _isGeneratingAi;

  KahootProvider(this._saveKahootUseCase);

  Kahoot get currentKahoot => _currentKahoot;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ... (Tus métodos setters existentes: setTitle, setDescription, etc. déjalos igual) ...
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
    print('🔴 [DEBUG provider] setThemeId llamado:');
    print('   themeId recibido: "$themeId"');
    print('   Longitud: ${themeId.length}');
    print('   ¿Es UUID válido?: ${RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$', caseSensitive: false).hasMatch(themeId)}');
    
    _currentKahoot = _currentKahoot.copyWith(themeId: themeId);
    
    print('   themeId después de copyWith: "${_currentKahoot.themeId}"');
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

  // ✅ NUEVO: Duplicar una pregunta específica
  void duplicateQuestion(int index) {
    if (index < 0 || index >= _currentKahoot.questions.length) return;
    
    final questionToDuplicate = _currentKahoot.questions[index];
    final duplicatedQuestion = questionToDuplicate.duplicate();
    
    final updatedQuestions = List<Question>.from(_currentKahoot.questions);
    updatedQuestions.insert(index + 1, duplicatedQuestion);
    
    _currentKahoot = _currentKahoot.copyWith(questions: updatedQuestions);
    notifyListeners();
  }

  // ✅ NUEVO: Cambiar puntuación de una pregunta
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

  // ✅ NUEVO: Reordenar preguntas
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

  // ✅ NUEVO MÉTODO: GENERAR CON IA
  Future<void> generateWithAi(String topic) async {
    _isGeneratingAi = true;
    _error = null;
    notifyListeners(); // Muestra el spinner de carga

    try {
      final aiService = sl<AiService>(); // Obtenemos el servicio inyectado
      final data = await aiService.generateFullQuiz(topic);

      if (data != null) {
        // 1. Actualizar Título y Descripción
        _currentKahoot = _currentKahoot.copyWith(
          title: data['title'] ?? 'Quiz IA',
          description: data['description'] ?? '',
        );

        // 2. Convertir JSON a Entidades (Question y Answer)
        final List<dynamic> questionsJson = data['questions'];
        final List<Question> newQuestions = [];

        for (var q in questionsJson) {
          // IDs temporales únicos para la UI
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

        // 3. Reemplazar preguntas actuales con las nuevas
        _currentKahoot = _currentKahoot.copyWith(questions: newQuestions);
      } else {
        _error = "La IA no pudo generar el quiz. Intenta otro tema.";
      }
    } catch (e) {
      _error = "Error conectando con IA: $e";
    } finally {
      _isGeneratingAi = false;
      notifyListeners(); // Oculta el spinner y actualiza la pantalla
    }
  }

  Future<void> saveKahoot() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 🔴 DEBUG ANTES DE GUARDAR
      print('🔴 [DEBUG provider saveKahoot] Antes de guardar:');
      print('   Título: ${_currentKahoot.title}');
      print('   ThemeId: "${_currentKahoot.themeId}"');
      print('   ¿ThemeId está vacío?: ${_currentKahoot.themeId.isEmpty}');
      
      if (_currentKahoot.themeId.isEmpty) {
        print('   ⚠️⚠️⚠️ ERROR: themeId está VACÍO!');
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
    print('🔴 [DEBUG provider] loadKahoot llamado:');
    print('   Kahoot ID: ${kahoot.id}');
    print('   ThemeId del kahoot cargado: "${kahoot.themeId}"');
    
    _currentKahoot = kahoot;
    notifyListeners();
  }

  // ✅ NUEVO: Validar si el kahoot está listo para guardar
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
}