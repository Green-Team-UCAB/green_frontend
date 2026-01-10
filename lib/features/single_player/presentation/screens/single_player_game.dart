import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:green_frontend/features/single_player/presentation/bloc/game_bloc.dart';
import 'package:green_frontend/features/single_player/presentation/bloc/game_state.dart';
import 'package:green_frontend/features/single_player/presentation/bloc/game_event.dart';
import 'package:green_frontend/features/single_player/domain/entities/answer.dart';
class SinglePlayerGameScreen extends StatefulWidget {
  const SinglePlayerGameScreen({super.key});

  @override
  State<SinglePlayerGameScreen> createState() => _SinglePlayerGameScreenState();
}

class _SinglePlayerGameScreenState extends State<SinglePlayerGameScreen> {
  
  Set<int> selectedIndices = {}; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<GameBloc, GameState>(
          builder: (context, state) {
            // Mostramos el puntaje acumulado dinámicamente
            int score = 0;
            if (state is GameInProgress) score = state.attempt.currentScore;
            if (state is GameAnswerFeedback) score = state.attempt.currentScore;
            return Text("Puntaje: $score");
          },
        ),
      ),
      body: BlocConsumer<GameBloc, GameState>(
        listener: (context, state) {
          // Al entrar a una nueva pregunta, limpiamos la selección
          if (state is GameInProgress) {
            setState(() => selectedIndices.clear());
          }
        },
        builder: (context, state) {
          if (state is GameInProgress || state is GameAnswerFeedback) {
            final isFeedback = state is GameAnswerFeedback;
            
            // Obtenemos el slide actual dependiendo del estado
            final slide = (state is GameInProgress) 
                ? state.attempt.nextSlide 
                : (state as GameAnswerFeedback).attempt.nextSlide;

            if (slide == null) return const Center(child: Text("¡Fin del juego!"));

            return Column(
              children: [
                const LinearProgressIndicator(value: 0.5),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(slide.questionText, 
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ),
                
                Expanded(
                  child: ListView.builder(
                    itemCount: slide.options.length,
                    itemBuilder: (context, index) {
                      final option = slide.options[index];
                      final isSelected = selectedIndices.contains(index);

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            // Resaltamos si está seleccionado
                            backgroundColor: isSelected ? Colors.deepPurple : Colors.white,
                            foregroundColor: isSelected ? Colors.white : Colors.black,
                            side: BorderSide(color: Colors.deepPurple.withOpacity(0.5)),
                          ),
                          // Si ya estamos en feedback, deshabilitamos la selección
                          onPressed: isFeedback ? null : () {
                            setState(() {
                              if (selectedIndices.contains(index)) {
                                selectedIndices.remove(index);
                              } else {
                                // Lógica: si es de selección única, limpiamos antes de añadir
                                // (Aquí podrías chequear slide.type si tu modelo lo tiene)
                                // selectedIndices.clear(); 
                                selectedIndices.add(index);
                              }
                            });
                          },
                          child: Text(option.text ?? ""),
                        ),
                      );
                    },
                  ),
                ),

                // AREA DINÁMICA: FEEDBACK O BOTÓN ENVIAR
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: isFeedback 
                    ? _buildFeedbackSection(state as GameAnswerFeedback)
                    : _buildSubmitButton(state as GameInProgress, slide.slideId),
                ),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  // Widget para enviar la respuesta (Seleccionada -> Procesando)
  Widget _buildSubmitButton(GameInProgress state, String slideId) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
        onPressed: selectedIndices.isEmpty ? null : () {
          context.read<GameBloc>().add(
            SubmitAnswerEvent(
              state.attempt.attemptId,
              Answer(
                slideId: slideId,
                answerIndex: selectedIndices.toList(), // Enviamos todos los seleccionados
                timeElapsedSeconds: 5,
              ),
            ),
          );
        },
        child: const Text("ENVIAR RESPUESTA", 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // Widget que muestra si acertó y el botón para pasar a la siguiente
  Widget _buildFeedbackSection(GameAnswerFeedback feedback) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: feedback.wasCorrect ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: feedback.wasCorrect ? Colors.green : Colors.red),
      ),
      child: Column(
        children: [
          Text(feedback.wasCorrect ? "¡CORRECTO!" : "INCORRECTO",
            style: TextStyle(
              fontSize: 20, 
              fontWeight: FontWeight.bold, 
              color: feedback.wasCorrect ? Colors.green : Colors.red
            )),
          Text("Ganaste ${feedback.pointsEarned} puntos", 
            style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
              onPressed: () {
                context.read<GameBloc>().add(NextQuestion(feedback.attempt.attemptId));
              },
              child: const Text("SIGUIENTE PREGUNTA", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}