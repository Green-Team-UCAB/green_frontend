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

  // Colores para las opciones (estilo Kahoot/Quiz premium)
  final List<Color> optionColors = [
    Colors.blue.shade600,
    Colors.red.shade600,
    Colors.orange.shade600,
    Colors.teal.shade600,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Fondo claro y limpio
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        title: BlocBuilder<GameBloc, GameState>(
          builder: (context, state) {
            int score = 0;
            if (state is GameInProgress) score = state.attempt.currentScore;
            if (state is GameAnswerFeedback) score = state.attempt.currentScore;
            if (state is GameFinished) return const Text("Resultados Finales", style: TextStyle(fontWeight: FontWeight.bold));
            
            return Text("Puntaje: $score", style: const TextStyle(fontWeight: FontWeight.bold));
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
          if (state is GameFinished) {
            return _buildSummaryScreen(state);
          }

          if (state is GameInProgress || state is GameAnswerFeedback) {
            final isFeedback = state is GameAnswerFeedback;
            final slide = (state is GameInProgress)
                ? state.attempt.nextSlide
                : (state as GameAnswerFeedback).attempt.nextSlide;

            if (slide == null) return const Center(child: CircularProgressIndicator());

            return Column(
              children: [
                // Barra de progreso superior
                const LinearProgressIndicator(
                  minHeight: 6,
                  backgroundColor: Color(0xFFE0E0E0),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                ),
                
                // Contenedor de la Pregunta (Centrada)
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    alignment: Alignment.center,
                    child: Text(
                      slide.questionText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                  ),
                ),

                // Grid de Respuestas (Distribuido 2x2)
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.2,
                      ),
                      itemCount: slide.options.length,
                      itemBuilder: (context, index) {
                        final isSelected = selectedIndices.contains(index);
                        final color = optionColors[index % optionColors.length];

                        return GestureDetector(
                          onTap: isFeedback ? null : () {
                            setState(() {
                              if (selectedIndices.contains(index)) {
                                selectedIndices.remove(index);
                              } else {
                                selectedIndices.add(index);
                              }
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isSelected ? color : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? Colors.white : color.withOpacity(0.4),
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Center(
                                child: Text(
                                  slide.options[index].text ?? "",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : color,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Espacio inferior para feedback o botón de envío
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
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

          return const Center(child: Text("Iniciando juego..."));
        },
      ),
    );
  }

  // Los métodos auxiliares se mantienen pero con leves ajustes estéticos

  Widget _buildSubmitButton(GameInProgress state, String slideId) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black, // Color sólido para el botón de acción principal
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
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
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildFeedbackSection(GameAnswerFeedback feedback) {
    final bool correct = feedback.wasCorrect;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: correct ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: correct ? Colors.green : Colors.red, width: 2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(correct ? Icons.check_circle : Icons.cancel, color: correct ? Colors.green : Colors.red),
              const SizedBox(width: 8),
              Text(correct ? "¡MUY BIEN!" : "¡SIGUE INTENTANDO!",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: correct ? Colors.green : Colors.red)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: correct ? Colors.green : Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                context.read<GameBloc>().add(NextQuestion(feedback.attempt.attemptId));
              },
              child: const Text("SIGUIENTE PREGUNTA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryScreen(GameFinished state) {
    final s = state.summary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.emoji_events_rounded, size: 100, color: Colors.amber),
          const SizedBox(height: 16),
          const Text("¡Increíble!", 
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900,color: Color(0xFF2D3436),)),
          const Text("Has completado el desafío", style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 32),
          _buildStatCard("PUNTAJE FINAL", "${s.finalScore}", Colors.deepPurple),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatCard("Correctas", "${s.totalCorrectAnswers}/${s.totalQuestions}", Colors.green)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard("Precisión", "${s.accuracyPercentage.toStringAsFixed(1)}%", Colors.blue)),
            ],
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("SALIR AL MENÚ", 
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: color, fontSize: 26, fontWeight: FontWeight.w900,)),
        ],
      ),
    );
  }
}