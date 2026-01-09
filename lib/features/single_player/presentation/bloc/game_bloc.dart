import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:green_frontend/features/single_player/application/start_attempt.dart';
import 'package:green_frontend/features/single_player/presentation/bloc/game_event.dart';
import 'package:green_frontend/features/single_player/presentation/bloc/game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final StartAttempt startAttempt;

  GameBloc({required this.startAttempt}) : super(GameInitial()) {
    on<StartGame>((event, emit) async {
      emit(GameLoading());
      final result = await startAttempt(kahootId: event.kahootId);
      result.match(
        (failure) => emit(GameError(failure.message)),
        (attempt) => emit(GameInProgress(attempt)),
      );
    });
  }
}
