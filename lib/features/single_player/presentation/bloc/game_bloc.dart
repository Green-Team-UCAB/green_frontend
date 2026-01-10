import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:green_frontend/features/single_player/application/start_attempt.dart';
import 'package:green_frontend/features/single_player/presentation/bloc/game_event.dart';
import 'package:green_frontend/features/single_player/presentation/bloc/game_state.dart';
import 'package:green_frontend/features/single_player/application/submit_answer.dart';
import 'package:green_frontend/features/single_player/application/get_summary.dart';
import 'package:green_frontend/features/single_player/domain/entities/attempt.dart';
import 'package:green_frontend/features/single_player/domain/entities/answer_result.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final StartAttempt startAttempt;
  final SubmitAnswer submitAnswer;
  final GetSummary getSummary;
  AnswerResult? _lastAnswerResult;

  GameBloc({
    required this.startAttempt,
    required this.submitAnswer,
    required this.getSummary,
  }) : super(GameInitial()) {
    
    // 1. Iniciar Juego
    on<StartGame>((event, emit) async {
      emit(GameLoading()); 
      final result = await startAttempt(kahootId: event.kahootId); 
      result.match(
        (failure) => emit(GameError(failure.message)), 
        (attempt) => emit(GameInProgress(attempt)), 
      );
    });

    // 2. Responder (Asegúrate de que esté AQUÍ, no dentro de StartGame)
    on<SubmitAnswerEvent>((event, emit) async {
      final result = await submitAnswer(event.attemptId, event.answer); 
      
      result.match(
        (failure) => emit(GameError(failure.message)),
        (answerResult) {
          _lastAnswerResult = answerResult; // Guardamos para el siguiente paso
          
          if (state is GameInProgress) {
            final currentState = state as GameInProgress;
            
            // EMITIMOS FEEDBACK en lugar de la siguiente pregunta directo
            emit(GameAnswerFeedback(
              attempt: currentState.attempt,
              wasCorrect: answerResult.wasCorrect,
              pointsEarned: answerResult.pointsEarned,
              nextScore: answerResult.updatedScore,
            ));
          }
        },
      );
    });

    on<NextQuestion>((event, emit) {
      if (_lastAnswerResult == null) return;

      if (_lastAnswerResult!.attemptState == AttemptState.completed) {
        add(FinishGame(event.attemptId));
      } else {
        final currentState = state;
        if (currentState is GameAnswerFeedback) {
          emit(GameInProgress(
            currentState.attempt.copyWith(
              nextSlide: _lastAnswerResult!.nextSlide,
              currentScore: _lastAnswerResult!.updatedScore,
            ),
          ));
        }
      }
    });

    // 3. Finalizar
    on<FinishGame>((event, emit) async {
      emit(GameLoading());
      
      final result = await getSummary(event.attemptId);
      
      result.match(
        (failure) => emit(GameError(failure.message)),
        (summary) {  
          print("JSON RECIBIDO: ${result.toString()}");
          print("DEBUG: Final Score: ${summary.finalScore}");
          print("DEBUG: Correctas: ${summary.totalCorrectAnswers}");
          print("DEBUG: Totales: ${summary.totalQuestions}");
          emit(GameFinished(summary));
        },
      );
    });
  }
}
