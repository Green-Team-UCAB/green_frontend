import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../application/get_my_kahoots_use_case.dart';
import '../../application/get_favorites_use_case.dart';
import '../../application/get_in_progress_use_case.dart';
import '../../application/get_completed_use_case.dart';
import '../../application/toggle_favorite_use_case.dart';
import '../../domain/entities/kahoot_summary.dart';

part 'library_event.dart';
part 'library_state.dart';

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  // Inyección de dependencias de la capa de Aplicación
  final GetMyKahootsUseCase getMyKahoots;
  final GetFavoritesUseCase getFavorites;
  final GetInProgressUseCase getInProgress;
  final GetCompletedUseCase getCompleted;
  final ToggleFavoriteUseCase toggleFavorite;

  LibraryBloc({
    required this.getMyKahoots,
    required this.getFavorites,
    required this.getInProgress,
    required this.getCompleted,
    required this.toggleFavorite,
  }) : super(LibraryInitial()) {
    // 1. Cargar Datos
    on<LoadLibraryDataEvent>((event, emit) async {
      // Solo emitimos Loading si es la primera vez o si queremos bloquear la pantalla.
      // Para Pull-to-refresh a veces se prefiere mantener los datos viejos,
      // pero para simplificar, emitimos loading aquí.
      emit(LibraryLoading());

      // Ejecutamos todos los casos de uso en paralelo para máxima velocidad
      final results = await Future.wait([
        getMyKahoots.call(),
        getFavorites.call(),
        getInProgress.call(),
        getCompleted.call(),
      ]);

      // Verificamos si hubo un error general (si todos fallaron)
      // O podemos ser más permisivos y mostrar lo que haya cargado.
      // Aquí asumimos que si falla MyKahoots, es un error crítico.
      final myKahootsResult = results[0];

      if (myKahootsResult.isLeft()) {
        emit(
          const LibraryError(
            "No se pudieron cargar los datos. Verifica tu conexión.",
          ),
        );
        return;
      }

      // Desempaquetamos los datos usando fold (fpdart)
      List<KahootSummary> creations = [];
      List<KahootSummary> favs = [];
      List<KahootSummary> progress = [];
      List<KahootSummary> done = [];

      results[0].fold((l) => null, (r) => creations = r);
      results[1].fold((l) => null, (r) => favs = r);
      results[2].fold((l) => null, (r) => progress = r);
      results[3].fold((l) => null, (r) => done = r);

      // --- CORRECCIÓN VISUAL: Sincronización de Favoritos ---
      // 1. Asegurar que la lista de favoritos tenga isFavorite = true
      favs = favs.map((k) => k.copyWith(isFavorite: true)).toList();

      // 2. Extraer IDs de favoritos
      final favIds = favs.map((e) => e.id).toSet();

      // 3. Cruzar datos con otras listas
      creations = creations
          .map((k) => favIds.contains(k.id) ? k.copyWith(isFavorite: true) : k)
          .toList();

      progress = progress
          .map((k) => favIds.contains(k.id) ? k.copyWith(isFavorite: true) : k)
          .toList();

      done = done
          .map((k) => favIds.contains(k.id) ? k.copyWith(isFavorite: true) : k)
          .toList();

      emit(
        LibraryLoaded(
          myCreations: creations,
          favorites: favs,
          inProgress: progress,
          completed: done,
        ),
      );
    });

    // 2. Toggle Favorito
    on<ToggleFavoriteInLibraryEvent>((event, emit) async {
      // Llamamos al caso de uso
      final result = await toggleFavorite.call(
        event.kahootId,
        event.isCurrentlyFavorite,
      );

      result.fold(
        (failure) {
          // Si falla, podríamos emitir un estado de error temporal o un evento side-effect.
          // Por ahora, no hacemos nada (la UI se queda igual).
        },
        (_) {
          // Si tuvo éxito, recargamos la data para actualizar las listas
          add(LoadLibraryDataEvent());
        },
      );
    });
  }
}
