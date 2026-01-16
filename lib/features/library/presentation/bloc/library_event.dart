part of 'library_bloc.dart';

abstract class LibraryEvent extends Equatable {
  const LibraryEvent();

  @override
  List<Object> get props => [];
}

/// Evento para cargar todas las listas (Mis Kahoots, Favoritos, Historial).
/// Sirve también para el Pull-to-Refresh.
class LoadLibraryDataEvent extends LibraryEvent {}

/// Evento cuando el usuario toca el corazón en una tarjeta.
class ToggleFavoriteInLibraryEvent extends LibraryEvent {
  final String kahootId;
  final bool isCurrentlyFavorite;

  const ToggleFavoriteInLibraryEvent({
    required this.kahootId,
    required this.isCurrentlyFavorite,
  });

  @override
  List<Object> get props => [kahootId, isCurrentlyFavorite];
}
