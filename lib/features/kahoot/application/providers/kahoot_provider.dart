import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../domain/entities/kahoot.dart';
import '../../domain/entities/question.dart';

class KahootProvider with ChangeNotifier {
  Kahoot _currentKahoot = Kahoot.empty();
  bool _isLoading = false;
  String? _error;

  Kahoot get currentKahoot => _currentKahoot;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setTitle(String title) {
    _currentKahoot.title = title;
    notifyListeners();
  }

  void setDescription(String description) {
    _currentKahoot.description = description;
    notifyListeners();
  }

  void setVisibility(String visibility) {
    _currentKahoot.visibility = visibility;
    notifyListeners();
  }

  void setThemeId(String themeId) {
    _currentKahoot.themeId = themeId;
    notifyListeners();
  }

  void setCategory(String category) {
    _currentKahoot.category = category;
    notifyListeners();
  }

  void setCoverImageId(String? coverImageId) {
    _currentKahoot.coverImageId = coverImageId;
    notifyListeners();
  }

  void addQuestion(Question question) {
    _currentKahoot.questions.add(question);
    notifyListeners();
  }

  void removeQuestion(int index) {
    _currentKahoot.questions.removeAt(index);
    notifyListeners();
  }

  void updateQuestion(int index, Question question) {
    _currentKahoot.questions[index] = question;
    notifyListeners();
  }

  Future<void> saveKahoot() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('http://tu-api.com/kahoots'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(_currentKahoot.toJson()),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        _currentKahoot.id = data['id'];
        _currentKahoot.createdAt = DateTime.parse(data['createdAt']);
      } else {
        _error = 'Error al guardar el Kahoot: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error de conexión: $e';
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