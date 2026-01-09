part of 'library_bloc.dart';

abstract class LibraryState extends Equatable {
  const LibraryState();

  @override
  List<Object> get props => [];
}

class LibraryInitial extends LibraryState {}

class LibraryLoading extends LibraryState {}

class LibraryError extends LibraryState {
  final String message;
  const LibraryError(this.message);

  @override
  List<Object> get props => [message];
}

class LibraryLoaded extends LibraryState {
  final List<KahootSummary> myCreations;
  final List<KahootSummary> favorites;
  final List<KahootSummary> inProgress;
  final List<KahootSummary> completed;

  const LibraryLoaded({
    this.myCreations = const [],
    this.favorites = const [],
    this.inProgress = const [],
    this.completed = const [],
  });

  /// Permite actualizar solo una parte del estado si fuera necesario
  LibraryLoaded copyWith({
    List<KahootSummary>? myCreations,
    List<KahootSummary>? favorites,
    List<KahootSummary>? inProgress,
    List<KahootSummary>? completed,
  }) {
    return LibraryLoaded(
      myCreations: myCreations ?? this.myCreations,
      favorites: favorites ?? this.favorites,
      inProgress: inProgress ?? this.inProgress,
      completed: completed ?? this.completed,
    );
  }

  @override
  List<Object> get props => [myCreations, favorites, inProgress, completed];
}
