import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../shared/domain/entities/kahoot_summary.dart';
import '../../domain/repositories/library_repository.dart';

// EVENTOS
abstract class LibraryEvent extends Equatable {
  const LibraryEvent();

  @override
  List<Object> get props => [];
}

class LoadLibraryDataEvent extends LibraryEvent {}

// ESTADOS
abstract class LibraryState extends Equatable {
  // CORRECCIÓN: Constructor const explícito para que los hijos puedan ser const
  const LibraryState();

  @override
  List<Object> get props => [];
}

class LibraryInitial extends LibraryState {}

class LibraryLoading extends LibraryState {}

class LibraryLoaded extends LibraryState {
  final List<KahootSummary> myKahoots;
  final List<KahootSummary> favorites;

  const LibraryLoaded({required this.myKahoots, required this.favorites});

  @override
  List<Object> get props => [myKahoots, favorites];
}

class LibraryError extends LibraryState {
  final String message;

  const LibraryError(this.message);

  @override
  List<Object> get props => [message];
}

// BLOC
class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  final LibraryRepository repository;

  LibraryBloc({required this.repository}) : super(LibraryInitial()) {
    on<LoadLibraryDataEvent>(_onLoadData);
  }

  Future<void> _onLoadData(
    LoadLibraryDataEvent event,
    Emitter<LibraryState> emit,
  ) async {
    emit(LibraryLoading());

    // Carga paralela de ambas listas
    final myKahootsResult = await repository.getMyKahoots();
    final favoritesResult = await repository.getFavorites();

    // Lógica: Si falla alguno, mostramos error. Si ambos cargan, mostramos data.
    myKahootsResult.fold((failure) => emit(LibraryError(failure.message)), (
      myKahoots,
    ) {
      favoritesResult.fold(
        (failure) => emit(LibraryError(failure.message)),
        (favorites) =>
            emit(LibraryLoaded(myKahoots: myKahoots, favorites: favorites)),
      );
    });
  }
}
