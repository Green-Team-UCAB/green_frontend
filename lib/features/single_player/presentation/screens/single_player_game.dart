import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:green_frontend/features/single_player/presentation/bloc/game_bloc.dart';
import 'package:green_frontend/features/single_player/presentation/bloc/game_state.dart';
import 'package:green_frontend/features/single_player/presentation/bloc/game_event.dart';
import 'package:green_frontend/features/single_player/domain/entities/answer.dart';
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
            int score = 0;
            if (state is GameInProgress) score = state.attempt.currentScore;
            if (state is GameAnswerFeedback) score = state.attempt.currentScore;
            
            // Si el juego terminó, no mostramos el puntaje en el AppBar porque ya está en el resumen
            if (state is GameFinished) return const Text("Resultados Finales");
            
            return Text("Puntaje: $score");
          },
        ),
      ),
      body: BlocConsumer<GameBloc, GameState>(
        listener: (context, state) {
          if (state is GameInProgress) {
            setState(() => selectedIndices.clear());
          }
        },
        builder: (context, state) {
          // 1. Manejo del estado final (Resumen)
          if (state is GameFinished) {
            return _buildSummaryScreen(state);
          }

          // 2. Manejo del juego en progreso o feedback
          if (state is GameInProgress || state is GameAnswerFeedback) {
            final isFeedback = state is GameAnswerFeedback;
            final slide = (state is GameInProgress)
                ? state.attempt.nextSlide
                : (state as GameAnswerFeedback).attempt.nextSlide;

            if (slide == null) return const Center(child: Text("Cargando resultados..."));

            return Column(
              children: [
                const LinearProgressIndicator(),
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
                            backgroundColor: isSelected ? Colors.deepPurple : Colors.white,
                            foregroundColor: isSelected ? Colors.white : Colors.black,
                            side: BorderSide(color: Colors.deepPurple.withOpacity(0.5)),
                          ),
                          onPressed: isFeedback ? null : () {
                            setState(() {
                              if (selectedIndices.contains(index)) {
                                selectedIndices.remove(index);
                              } else {
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
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: isFeedback
                      ? _buildFeedbackSection(state as GameAnswerFeedback)
                      : _buildSubmitButton(state as GameInProgress, slide.slideId),
                ),
              ],
            );
          }

          if (state is GameLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is GameError) {
            return Center(child: Text("Error: ${state.message}"));
          }

          return const Center(child: Text("Iniciando juego..."));
        },
      ),
    );
  }

  // --- NUEVA VISTA DE RESUMEN ---
  Widget _buildSummaryScreen(GameFinished state) {
    final s = state.summary; // Usando tu entidad Summary
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.stars, size: 80, color: Colors.amber),
          const SizedBox(height: 16),
          const Text("¡Juego Terminado!", 
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          
          _buildStatCard("Puntaje Total", "${s.finalScore}", Colors.deepPurple),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  "Correctas", 
                  "${s.totalCorrectAnswers}/${s.totalQuestions}", 
                  Colors.green
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  "Precisión", 
                  "${s.accuracyPercentage.toStringAsFixed(1)}%", 
                  Colors.blue
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("VOLVER A LA BIBLIOTECA", 
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

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
                answerIndex: selectedIndices.toList(),
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
                  color: feedback.wasCorrect ? Colors.green : Colors.red)),
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