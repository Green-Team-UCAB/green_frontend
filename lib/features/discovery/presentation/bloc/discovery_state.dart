import 'package:equatable/equatable.dart';

abstract class DiscoveryState extends Equatable {
  const DiscoveryState();

  @override
  List<Object?> get props => [];
}

class DiscoveryInitial extends DiscoveryState {}

class DiscoveryLoading extends DiscoveryState {}

class DiscoveryLoaded extends DiscoveryState {
  // Datos Fijos (Cargados al inicio)
  final List<dynamic> featuredQuizzes;
  final List<String> categories;

  // Estado de Búsqueda
  final List<dynamic> searchResults; // Resultados de la búsqueda actual
  final String activeCategory; // Categoría seleccionada (vacío = todas)
  final String searchQuery; // Texto actual del buscador
  final bool isSearching; // True si estamos esperando respuesta del back

  const DiscoveryLoaded({
    required this.featuredQuizzes,
    required this.categories,
    this.searchResults = const [],
    this.activeCategory = '',
    this.searchQuery = '',
    this.isSearching = false,
  });

  /// Método helper para actualizar el estado parcialmente (copyWith)
  DiscoveryLoaded copyWith({
    List<dynamic>? featuredQuizzes,
    List<String>? categories,
    List<dynamic>? searchResults,
    String? activeCategory,
    String? searchQuery,
    bool? isSearching,
  }) {
    return DiscoveryLoaded(
      featuredQuizzes: featuredQuizzes ?? this.featuredQuizzes,
      categories: categories ?? this.categories,
      searchResults: searchResults ?? this.searchResults,
      activeCategory: activeCategory ?? this.activeCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      isSearching: isSearching ?? this.isSearching,
    );
  }

  @override
  List<Object?> get props => [
    featuredQuizzes,
    categories,
    searchResults,
    activeCategory,
    searchQuery,
    isSearching,
  ];
}

class DiscoveryError extends DiscoveryState {
  final String message;
  const DiscoveryError(this.message);

  @override
  List<Object> get props => [message];
}
