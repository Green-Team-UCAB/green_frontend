import 'package:flutter/material.dart';
import 'package:green_frontend/features/kahoot/application/use_cases/save_kahoot_use_case.dart';
import 'package:green_frontend/features/kahoot/domain/entities/kahoot.dart';
import 'package:green_frontend/features/kahoot/domain/entities/question.dart';


class KahootProvider with ChangeNotifier {
  Kahoot _currentKahoot = Kahoot.empty();
  bool _isLoading = false;
  String? _error;
  
  final SaveKahootUseCase _saveKahootUseCase;

  KahootProvider(this._saveKahootUseCase);

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
    final updatedQuestions = List<Question>.from(_currentKahoot.questions)..add(question);
    _currentKahoot = _currentKahoot.copyWith(questions: updatedQuestions);
    notifyListeners();
  }

  void removeQuestion(int index) {
    final updatedQuestions = List<Question>.from(_currentKahoot.questions)..removeAt(index);
    _currentKahoot = _currentKahoot.copyWith(questions: updatedQuestions);
    notifyListeners();
  }

  void updateQuestion(int index, Question question) {
    final updatedQuestions = List<Question>.from(_currentKahoot.questions);
    updatedQuestions[index] = question;
    _currentKahoot = _currentKahoot.copyWith(questions: updatedQuestions);
    notifyListeners();
  }

  Future<void> saveKahoot() async {
    _isLoading = true;
    _error = null;
    
    notifyListeners();

    try {
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
}