part of 'discovery_bloc.dart';

abstract class DiscoveryEvent extends Equatable {
  const DiscoveryEvent();

  @override
  List<Object> get props => [];
}

class DiscoveryStarted extends DiscoveryEvent {}

class SearchQueryChanged extends DiscoveryEvent {
  final String query;

  const SearchQueryChanged(this.query);

  @override
  List<Object> get props => [query];
}

class CategorySelected extends DiscoveryEvent {
  final String categoryId;
  final String categoryName;

  const CategorySelected({
    required this.categoryId,
    required this.categoryName,
  });

  @override
  List<Object> get props => [categoryId, categoryName];
}

// Evento para quitar filtros y volver al inicio
class DiscoveryFilterCleared extends DiscoveryEvent {}
