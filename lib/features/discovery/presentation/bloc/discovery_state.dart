part of 'discovery_bloc.dart';

enum DiscoveryStatus { initial, loading, success, failure }

class DiscoveryState extends Equatable {
  final DiscoveryStatus status;
  final List<KahootSummary> featuredKahoots;
  final List<Category> categories;
  final List<KahootSummary> searchResults;
  final String errorMessage;
  // NUEVO CAMPO: Para saber qué filtro está activo
  final String? selectedCategoryName;

  const DiscoveryState({
    this.status = DiscoveryStatus.initial,
    this.featuredKahoots = const [],
    this.categories = const [],
    this.searchResults = const [],
    this.errorMessage = '',
    this.selectedCategoryName, // Null significa que no hay categoría seleccionada
  });

  DiscoveryState copyWith({
    DiscoveryStatus? status,
    List<KahootSummary>? featuredKahoots,
    List<Category>? categories,
    List<KahootSummary>? searchResults,
    String? errorMessage,
    String? Function()?
    selectedCategoryName, // Truco para permitir asignar null
  }) {
    return DiscoveryState(
      status: status ?? this.status,
      featuredKahoots: featuredKahoots ?? this.featuredKahoots,
      categories: categories ?? this.categories,
      searchResults: searchResults ?? this.searchResults,
      errorMessage: errorMessage ?? this.errorMessage,
      // Si pasan la función, la ejecutan (permite null), si no, mantienen el valor actual
      selectedCategoryName: selectedCategoryName != null
          ? selectedCategoryName()
          : this.selectedCategoryName,
    );
  }

  @override
  List<Object?> get props => [
    status,
    featuredKahoots,
    categories,
    searchResults,
    errorMessage,
    selectedCategoryName,
  ];
}
