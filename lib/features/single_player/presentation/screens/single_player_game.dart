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

  final List<Color> optionColors = [
    Colors.blue.shade600,
    Colors.red.shade600,
    Colors.orange.shade600,
    Colors.teal.shade600,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
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
            if (state is GameFinished) {
              return const Text("Resultados Finales",
                  style: TextStyle(fontWeight: FontWeight.bold));
            }
            return Text("Puntaje: $score",
                style: const TextStyle(fontWeight: FontWeight.bold));
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
          if (state is GameError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline_rounded,
                        size: 80, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    const Text(
                      "Opps!",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style:
                          const TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Volver"),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is GameFinished) return _buildSummaryScreen(state);

          if (state is GameInProgress || state is GameAnswerFeedback) {
            final isFeedback = state is GameAnswerFeedback;
            final slide = (state is GameInProgress)
                ? state.attempt.nextSlide
                : (state as GameAnswerFeedback).attempt.nextSlide;

            if (slide == null)
              return const Center(child: CircularProgressIndicator());

            return Column(
              children: [
                const LinearProgressIndicator(
                  minHeight: 6,
                  backgroundColor: Color(0xFFE0E0E0),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                ),

                // ÁREA DE PREGUNTA DINÁMICA (CON O SIN IMAGEN)
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (slide.mediaID != null && slide.mediaID!.isNotEmpty)
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 10,
                                  )
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  slide.mediaID!,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        Text(
                          slide.questionText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF2D3436),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // layout dinamico
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 250,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.3,
                      ),
                      itemCount: slide.options.length,
                      itemBuilder: (context, index) {
                        final option = slide.options[index];
                        final isSelected = selectedIndices.contains(index);
                        final color = optionColors[index % optionColors.length];

                        return GestureDetector(
                          onTap: isFeedback
                              ? null
                              : () {
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
                                color: isSelected
                                    ? Colors.white
                                    : color.withValues(alpha: 0.4),
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: _buildOptionContent(
                                  option, isSelected, color),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                  child: isFeedback
                      ? _buildFeedbackSection(state as GameAnswerFeedback)
                      : _buildSubmitButton(
                          state as GameInProgress, slide.slideId),
                ),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  // MÉTODO PARA RENDERIZAR CONTENIDO DE OPCIÓN (TEXTO O IMAGEN)
  Widget _buildOptionContent(dynamic option, bool isSelected, Color color) {
    // Option es una imagen
    if (option.mediaID != null && option.mediaID!.isNotEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            option.mediaID!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image),
          ),
          if (isSelected)
            Container(
              color: color.withValues(alpha: 0.4),
              child:
                  const Icon(Icons.check_circle, color: Colors.white, size: 40),
            ),
        ],
      );
    }

    // Option es un texto
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(
          option.text ?? "",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : color,
          ),
        ),
      ),
    );
  }

  // --- MÉTODOS AUXILIARES (SE MANTIENEN PERO CON EL FIX DE FONTWEIGHT) ---

  Widget _buildSubmitButton(GameInProgress state, String slideId) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: selectedIndices.isEmpty
            ? null
            : () {
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
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
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
        border:
            Border.all(color: correct ? Colors.green : Colors.red, width: 2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(correct ? Icons.check_circle : Icons.cancel,
                  color: correct ? Colors.green : Colors.red),
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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                context
                    .read<GameBloc>()
                    .add(NextQuestion(feedback.attempt.attemptId));
              },
              child: const Text("SIGUIENTE PREGUNTA",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryScreen(GameFinished state) {
    final s = state.summary;
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events_rounded,
                size: 100, color: Colors.amber),
            const SizedBox(height: 16),
            const Text("¡Increíble!",
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2D3436))),
            const Text("Has completado el desafío",
                style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 32),
            _buildStatCard(
                "PUNTAJE FINAL", "${s.finalScore}", Colors.deepPurple),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: _buildStatCard(
                        "Correctas",
                        "${s.totalCorrectAnswers}/${s.totalQuestions}",
                        Colors.green)),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildStatCard(
                        "Precisión",
                        "${s.accuracyPercentage.toStringAsFixed(1)}%",
                        Colors.blue)),
              ],
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16))),
                onPressed: () => Navigator.pop(context),
                child: const Text("SALIR AL MENÚ",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        children: [
          Text(label,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 26, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
