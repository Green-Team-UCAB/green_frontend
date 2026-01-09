import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../library/domain/entities/kahoot_summary.dart';
import '../../../library/application/get_my_kahoots_use_case.dart';

// EVENTS
abstract class KahootSelectionEvent {}

class LoadMyKahootsEvent extends KahootSelectionEvent {}

// STATES
abstract class KahootSelectionState {}

class KahootSelectionLoading extends KahootSelectionState {}

class KahootSelectionLoaded extends KahootSelectionState {
  final List<KahootSummary> kahoots;
  KahootSelectionLoaded(this.kahoots);
}

class KahootSelectionError extends KahootSelectionState {
  final String message;
  KahootSelectionError(this.message);
}

// BLOC
class KahootSelectionBloc
    extends Bloc<KahootSelectionEvent, KahootSelectionState> {
  final GetMyKahootsUseCase getMyKahoots;

  KahootSelectionBloc({required this.getMyKahoots})
    : super(KahootSelectionLoading()) {
    on<LoadMyKahootsEvent>(_onLoadMyKahoots);
  }

  Future<void> _onLoadMyKahoots(
    LoadMyKahootsEvent event,
    Emitter<KahootSelectionState> emit,
  ) async {
    emit(KahootSelectionLoading());
    final result = await getMyKahoots();
    result.fold(
      (failure) => emit(KahootSelectionError(failure.message)),
      (kahoots) => emit(KahootSelectionLoaded(kahoots)),
    );
  }
}
