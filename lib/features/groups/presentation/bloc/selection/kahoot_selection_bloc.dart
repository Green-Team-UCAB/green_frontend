import 'package:bloc/bloc.dart';
import '../../../domain/repositories/groups_repository.dart';
import 'kahoot_selection_event.dart';
import 'kahoot_selection_state.dart';

class KahootSelectionBloc
    extends Bloc<KahootSelectionEvent, KahootSelectionState> {
  final GroupsRepository repository;

  KahootSelectionBloc({required this.repository})
    : super(KahootSelectionInitial()) {
    on<LoadMyKahootsEvent>((event, emit) async {
      emit(KahootSelectionLoading());

      final result = await repository.getMyKahoots();

      result.fold(
        (failure) => emit(KahootSelectionError(failure.toString())),
        (kahoots) => emit(KahootSelectionLoaded(kahoots)),
      );
    });
  }
}
