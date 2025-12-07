import 'package:flutter/material.dart';
import 'package:green_frontend/features/kahoot/domain/entities/theme_image.dart';
import 'package:green_frontend/features/kahoot/domain/repositories/itheme_repository.dart';

class ThemeProvider with ChangeNotifier {
  List<ThemeImage> _themes = [];
  bool _isLoading = false;
  String? _error;

  final ThemeRepository themeRepository;

  ThemeProvider({required this.themeRepository});

  List<ThemeImage> get themes => _themes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadThemes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _themes = await themeRepository.getThemes();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}