import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:green_frontend/features/single_player/infraestructure/datasources/async_game_datasource.dart';
import 'game_event.dart';
import 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final AsyncGameDataSource dataSource;

  GameBloc(this.dataSource) : super(GameInitial()) {
    on<StartGame>((event, emit) async {
      emit(GameLoading());
      try {
        final attempt = await dataSource.startAttempt(kahootId: event.kahootId);
        emit(GameInProgress(attempt));
      } catch (e) {
        emit(GameError(e.toString()));
      }
    });

    on<SubmitAnswerEvent>((event, emit) async {
      try {
        final result = await dataSource.submitAnswer(
          attemptId: event.attemptId,
          answer: event.answer,
        );
        // Aquí podrías actualizar el estado del juego con la respuesta
      } catch (e) {
        emit(GameError(e.toString()));
      }
    });

    on<FinishGame>((event, emit) async {
      try {
        final summary = await dataSource.getSummary(attemptId: event.attemptId);
        emit(GameFinished(summary));
      } catch (e) {
        emit(GameError(e.toString()));
      }
    });
  }
}
