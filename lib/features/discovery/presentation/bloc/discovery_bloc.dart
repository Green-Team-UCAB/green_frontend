import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/discovery_repository.dart';
import '../../../shared/domain/entities/kahoot_summary.dart';
import '../../../shared/domain/entities/category.dart';

part 'discovery_event.dart';
part 'discovery_state.dart';

class DiscoveryBloc extends Bloc<DiscoveryEvent, DiscoveryState> {
  final DiscoveryRepository repository;

  DiscoveryBloc({required this.repository}) : super(const DiscoveryState()) {
    on<DiscoveryStarted>(_onDiscoveryStarted);
    on<SearchQueryChanged>(
      _onSearchQueryChanged,
      transformer: (events, mapper) => events
          .debounceTime(const Duration(milliseconds: 500))
          .switchMap(mapper),
    );
    on<CategorySelected>(_onCategorySelected);
    on<DiscoveryFilterCleared>(_onDiscoveryFilterCleared);
  }

  Future<void> _onDiscoveryStarted(
    DiscoveryStarted event,
    Emitter<DiscoveryState> emit,
  ) async {
    emit(state.copyWith(status: DiscoveryStatus.loading));

    final results = await Future.wait([
      repository.getFeaturedKahoots(),
      repository.getCategories(),
    ]);

    final featuredResult = results[0] as Either<Failure, List<KahootSummary>>;
    final categoriesResult = results[1] as Either<Failure, List<Category>>;

    List<KahootSummary> featured = [];
    List<Category> cats = [];
    String? error;

    featuredResult.fold((l) => error = l.message, (r) => featured = r);
    categoriesResult.fold((l) => error = l.message, (r) => cats = r);

    if (error != null) {
      emit(
        state.copyWith(status: DiscoveryStatus.failure, errorMessage: error),
      );
    } else {
      emit(
        state.copyWith(
          status: DiscoveryStatus.success,
          featuredKahoots: featured,
          categories: cats,
        ),
      );
    }
  }

  Future<void> _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<DiscoveryState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(
        state.copyWith(
          status: DiscoveryStatus.success,
          searchResults: [],
          selectedCategoryName: () => null, // Limpiamos categoría si borra
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: DiscoveryStatus.loading,
        selectedCategoryName: () => null, // Búsqueda manual anula categoría
      ),
    );

    final result = await repository.searchKahoots(event.query);

    result.fold(
      (l) => emit(
        state.copyWith(
          status: DiscoveryStatus.failure,
          errorMessage: l.message,
        ),
      ),
      (r) => emit(
        state.copyWith(status: DiscoveryStatus.success, searchResults: r),
      ),
    );
  }

  Future<void> _onCategorySelected(
    CategorySelected event,
    Emitter<DiscoveryState> emit,
  ) async {
    emit(
      state.copyWith(
        status: DiscoveryStatus.loading,
        selectedCategoryName: () => event.categoryName, // Guardamos el nombre
      ),
    );

    final result = await repository.searchKahoots(
      '',
      categoryId: event.categoryName,
    );

    result.fold(
      (l) => emit(
        state.copyWith(
          status: DiscoveryStatus.failure,
          errorMessage: l.message,
        ),
      ),
      (r) => emit(
        state.copyWith(status: DiscoveryStatus.success, searchResults: r),
      ),
    );
  }

  void _onDiscoveryFilterCleared(
    DiscoveryFilterCleared event,
    Emitter<DiscoveryState> emit,
  ) {
    emit(
      state.copyWith(
        status: DiscoveryStatus.success,
        searchResults: [], // Ocultar lista
        selectedCategoryName: () => null, // Quitar nombre de categoría
      ),
    );
  }
}
