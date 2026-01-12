import 'package:flutter/material.dart';
import 'package:green_frontend/features/discovery/data/datasources/discovery_remote_data_source.dart';
class CategoryProvider with ChangeNotifier {
  List<String> _categories = [];
  bool _isLoading = false;
  String? _error;
  
  final DiscoveryRemoteDataSource _dataSource;

  CategoryProvider({required DiscoveryRemoteDataSource dataSource})
      : _dataSource = dataSource;

  List<String> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categories = await _dataSource.getCategories();
    } catch (e) {
      _error = 'Error al cargar categorías: $e';
      // Categorías por defecto en caso de error
      _categories = [
        "Matemáticas",
        "Ciencias",
        "Historia",
        "Geografía",
        "Arte",
        "Tecnología",
        "Idiomas",
        "Deportes",
        "Cine y TV",
        "Cultura General",
      ];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}