import 'package:bloc/bloc.dart';
import '../../domain/repositories/discovery_repository.dart';
import 'discovery_event.dart';
import 'discovery_state.dart';
// Importamos stream_transform para el debounce (evitar mil peticiones al escribir)
import 'package:stream_transform/stream_transform.dart';

// Tiempo de espera para dejar de escribir antes de buscar (Debounce)
const _duration = Duration(milliseconds: 500);

EventTransformer<Event> debounce<Event>(Duration duration) {
  return (events, mapper) => events.debounce(duration).switchMap(mapper);
}

class DiscoveryBloc extends Bloc<DiscoveryEvent, DiscoveryState> {
  final DiscoveryRepository repository;

  DiscoveryBloc({required this.repository}) : super(DiscoveryInitial()) {
    // 1. Carga Inicial (Destacados y Categorías)
    on<LoadDiscoveryDataEvent>((event, emit) async {
      emit(DiscoveryLoading());

      // Hacemos las dos peticiones en paralelo para ganar tiempo
      final results = await Future.wait([
        repository.getFeaturedQuizzes(),
        repository.getCategories(),
      ]);

      final featuredResult =
          results[0] as dynamic; // Either<Failure, List<dynamic>>
      final categoriesResult =
          results[1] as dynamic; // Either<Failure, List<String>>

      List<dynamic> featured = [];
      List<String> categories = [];

      featuredResult.fold((l) => null, (r) => featured = r);
      categoriesResult.fold((l) => null, (r) => categories = r);

      // Si fallan ambas cosas críticas, mostramos error, sino mostramos lo que haya
      if (featured.isEmpty && categories.isEmpty && featuredResult.isLeft()) {
        emit(
          const DiscoveryError(
            "No se pudo cargar el contenido. Revisa tu conexión.",
          ),
        );
      } else {
        emit(
          DiscoveryLoaded(featuredQuizzes: featured, categories: categories),
        );
      }
    });

    // 2. Búsqueda por Texto (Con Debounce para no saturar API)
    on<SearchQuizzesEvent>(_onSearchChanged, transformer: debounce(_duration));

    // 3. Filtrar por Categoría
    on<ToggleCategoryEvent>(_onCategoryChanged);

    // 4. Limpiar
    on<ClearSearchEvent>((event, emit) {
      if (state is DiscoveryLoaded) {
        final currentState = state as DiscoveryLoaded;
        emit(
          currentState.copyWith(
            searchQuery: '',
            searchResults: [],
            isSearching: false,
          ),
        );
      }
    });
  }

  Future<void> _onSearchChanged(
    SearchQuizzesEvent event,
    Emitter<DiscoveryState> emit,
  ) async {
    if (state is DiscoveryLoaded) {
      final currentState = state as DiscoveryLoaded;

      // Si el texto está vacío, limpiamos resultados de búsqueda pero mantenemos categoría
      if (event.query.isEmpty) {
        emit(
          currentState.copyWith(
            searchQuery: '',
            searchResults: [],
            isSearching: false,
          ),
        );
        // Si hay categoría seleccionada, deberíamos buscar solo por categoría
        if (currentState.activeCategory.isNotEmpty) {
          add(ToggleCategoryEvent(currentState.activeCategory));
        }
        return;
      }

      emit(currentState.copyWith(searchQuery: event.query, isSearching: true));

      await _performSearch(emit, currentState.activeCategory, event.query);
    }
  }

  Future<void> _onCategoryChanged(
    ToggleCategoryEvent event,
    Emitter<DiscoveryState> emit,
  ) async {
    if (state is DiscoveryLoaded) {
      final currentState = state as DiscoveryLoaded;

      // Lógica de Toggle: Si toco la misma categoría, la desactivo.
      final newCategory = (currentState.activeCategory == event.category)
          ? ''
          : event.category;

      emit(
        currentState.copyWith(activeCategory: newCategory, isSearching: true),
      );

      // Si no hay texto ni categoría, limpiamos resultados
      if (newCategory.isEmpty && currentState.searchQuery.isEmpty) {
        emit(
          currentState.copyWith(
            activeCategory: '',
            searchResults: [],
            isSearching: false,
          ),
        );
        return;
      }

      await _performSearch(emit, newCategory, currentState.searchQuery);
    }
  }

  // Helper para ejecutar la búsqueda en el repositorio
  Future<void> _performSearch(
    Emitter<DiscoveryState> emit,
    String category,
    String query,
  ) async {
    if (state is DiscoveryLoaded) {
      final currentState = state as DiscoveryLoaded;

      // Preparamos lista de categorías (la API espera lista, aunque aquí enviamos una)
      final categoriesList = category.isNotEmpty ? [category] : null;

      final result = await repository.searchQuizzes(
        query: query,
        categories: categoriesList,
      );

      result.fold(
        (failure) => emit(
          currentState.copyWith(isSearching: false, searchResults: []),
        ), // O manejar error
        (quizzes) => emit(
          currentState.copyWith(isSearching: false, searchResults: quizzes),
        ),
      );
    }
  }
}
