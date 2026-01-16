import 'package:equatable/equatable.dart';

abstract class DiscoveryEvent extends Equatable {
  const DiscoveryEvent();

  @override
  List<Object?> get props => [];
}

/// Evento inicial para cargar destacados y categorías (y Pull-to-Refresh)
class LoadDiscoveryDataEvent extends DiscoveryEvent {}

/// Evento cuando el usuario escribe en el buscador
class SearchQuizzesEvent extends DiscoveryEvent {
  final String query;
  const SearchQuizzesEvent(this.query);

  @override
  List<Object> get props => [query];
}

/// Evento cuando el usuario selecciona (o deselecciona) una categoría
class ToggleCategoryEvent extends DiscoveryEvent {
  final String category;
  const ToggleCategoryEvent(this.category);

  @override
  List<Object> get props => [category];
}

/// Evento para limpiar la búsqueda y volver al inicio
class ClearSearchEvent extends DiscoveryEvent {}
