import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:green_frontend/features/single_player/presentation/provider/game_provider.dart';

class SummaryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resumen')),
      body: Consumer<GameController>(
        builder: (context, controller, child) {
          if (controller.isLoading) return const Center(child: CircularProgressIndicator());
          if (controller.summary == null) return const Center(child: Text('No hay resumen'));

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text('Puntuación Final: ${controller.summary!.finalScore}'),
                Text('Correctas: ${controller.summary!.totalCorrectAnswers}/${controller.summary!.totalQuestions}'),
                // Agrega lista de respuestas si disponible
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                  child: const Text('Volver al Inicio'),
                ),
                ElevatedButton(
                  onPressed: () => _repeatKahoot(context, controller),
                  child: const Text('Repetir Kahoot'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _repeatKahoot(BuildContext context, GameController controller) {
    // Asume que tienes kahootId guardado; reinicia y navega a GamePage
    controller.reset();
    // Llama startNewAttempt y navega
  }
}