import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/discovery_repository.dart';
import '../../../shared/domain/entities/kahoot_summary.dart';

part 'discovery_event.dart';
part 'discovery_state.dart';

class DiscoveryBloc extends Bloc<DiscoveryEvent, DiscoveryState> {
  final DiscoveryRepository repository;

  DiscoveryBloc({required this.repository}) : super(DiscoveryInitial()) {
    on<SearchQueryChanged>(_onSearchQueryChanged);
  }

  // Debounce manual podría implementarse aquí para evitar muchas llamadas
  Future<void> _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<DiscoveryState> emit,
  ) async {
    emit(DiscoveryLoading());

    final result = await repository.searchKahoots(event.query);

    result.fold(
      (failure) => emit(DiscoveryError(failure.message)),
      (kahoots) => emit(DiscoveryLoaded(kahoots)),
    );
  }
}
