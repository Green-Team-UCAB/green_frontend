import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ThemeImage {
  final String id;
  final String name;
  final String imageUrl;

  ThemeImage({
    required this.id,
    required this.name,
    required this.imageUrl,
  });
}

class ThemeProvider with ChangeNotifier {
  List<ThemeImage> _themes = [];
  bool _isLoading = false;
  String? _error;

  List<ThemeImage> get themes => _themes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadThemes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulación de datos - en producción usarías la API real
      await Future.delayed(Duration(seconds: 1));
      
      _themes = [
        ThemeImage(
          id: '1',
          name: 'Cosmos',
          imageUrl: 'https://cdn.eso.org/images/screen/eso1213a.jpg',
        ),
        ThemeImage(
          id: '2',
          name: 'Winter',
          imageUrl: 'https://via.placeholder.com/150/1565C0/FFFFFF?text=Winter',
        ),
        ThemeImage(
          id: '3',
          name: 'Spring',
          imageUrl: 'https://via.placeholder.com/150/2E7D32/FFFFFF?text=Spring',
        ),
        ThemeImage(
          id: '4',
          name: 'Summer',
          imageUrl: 'https://via.placeholder.com/150/FF8F00/FFFFFF?text=Summer',
        ),
        ThemeImage(
          id: '5',
          name: 'Autumn',
          imageUrl: 'https://via.placeholder.com/150/D84315/FFFFFF?text=Autumn',
        ),
        ThemeImage(
          id: '6',
          name: 'Support Ukraine',
          imageUrl: 'https://via.placeholder.com/150/0057B7/FFD700?text=Ukraine',
        ),
      ];
    } catch (e) {
      _error = 'Error al cargar temas: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}