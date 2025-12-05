import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:green_frontend/features/single_player/presentation/provider/game_provider.dart';
import 'package:green_frontend/features/single_player/domain/entities/answer.dart';


class GamePage extends StatefulWidget {
  final String attemptId;
  const GamePage({required this.attemptId, super.key});

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  Set<int> selectedIndices = {};  // Para selección múltiple

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Juego')),
      body: Consumer<GameController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.lastFailure != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${controller.lastFailure!.message}')),
              );
            });
            return const Center(child: Text('Ocurrió un error. Reintenta.'));
          }
          if (controller.currentSlide == null) {
            return const Center(child: Text('No hay pregunta'));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Pregunta
                Text(
                  controller.currentSlide!.questionText,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // Puntuación
                Text(
                  'Puntuación: ${controller.attempt?.currentScore ?? 0}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                // Opciones como checkboxes (selección múltiple)
                Expanded(
                  child: ListView(
                    children: (controller.currentSlide!.options as List).asMap().entries.map((entry) {
                      final index = entry.key;  // Índice (0, 1, 2, ...)
                      final option = entry.value;
                      final optionText = option.text ?? option.label ?? option.toString();  // Texto de la opción
                      return CheckboxListTile(
                        title: Text(optionText, style: const TextStyle(fontSize: 16)),
                        value: selectedIndices.contains(index),
                        onChanged: controller.isSubmitting
                            ? null
                            : (bool? selected) {
                                setState(() {
                                  if (selected == true) {
                                    selectedIndices.add(index);
                                  } else {
                                    selectedIndices.remove(index);
                                  }
                                });
                              },
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
                // Botón para enviar respuesta
                ElevatedButton(
                  onPressed: controller.isSubmitting || selectedIndices.isEmpty
                      ? null
                      : () => _submitAnswer(context, controller),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16.0),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Enviar Respuesta', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 20),
                // Feedback
                if (controller.showFeedback)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    color: controller.wasCorrect ? Colors.green : Colors.red,
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      controller.wasCorrect
                          ? '¡Correcto! +${controller.pointsEarned} puntos'
                          : 'Incorrecto. +${controller.pointsEarned} puntos',
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _submitAnswer(BuildContext context, GameController controller) async {
    final answerEntity = Answer(
      slideId: controller.currentSlide!.slideId,
      answerIndex: selectedIndices.toList(),  // Lista de índices seleccionados
      timeElapsedSeconds: null,
    );
    await controller.submitAnswerResult(answerEntity, context);
    setState(() => selectedIndices.clear());  // Limpia para la siguiente pregunta
  }
}