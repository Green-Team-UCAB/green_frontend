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
  Set<int> selectedIndices = {}; // Para selección múltiple
  DateTime? startTime;

  // Colores para las opciones como en la imagen
  final List<Color> optionColors = [
    Colors.blue,
    Colors.red,
    Colors.orange,
    Colors.green,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<GameController>();
      if (controller.currentSlide != null) {
        startTime = DateTime.now();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco
      appBar: AppBar(
        title: const Text('Juego'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Consumer<GameController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.lastFailure != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Error: ${controller.lastFailure!.message}')),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progreso como en la imagen
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "1/10 Quiz", // Cambiar esto por datos dinámicos si los tienes
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Puntuación: ${controller.attempt?.currentScore ?? 0}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: 0.1, // Cambiar por progreso real
                  backgroundColor: Colors.grey.shade300,
                  color: Colors.purple,
                ),
                const SizedBox(height: 16),

                // Imagen del autobús (si hay mediaId)
                if (controller.currentSlide!.mediaId != null &&
                    controller.currentSlide!.mediaId!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      controller.currentSlide!.mediaId!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 180,
                        color: Colors.grey.shade200,
                        child: const Center(
                            child: Icon(Icons.image_not_supported)),
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                // Pregunta
                Text(
                  controller.currentSlide!.questionText,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),

                // Opciones como botones de colores (2 columnas)
                Expanded(
                  child: _buildOptionsGrid(controller, context),
                ),
                const SizedBox(height: 20),

                // Botón para enviar respuesta
                ElevatedButton(
                  onPressed: controller.isSubmitting || selectedIndices.isEmpty
                      ? null
                      : () => _submitAnswer(context, controller),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16.0),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: controller.isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Enviar Respuesta',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
                const SizedBox(height: 20),

                // Feedback
                if (controller.showFeedback)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: controller.wasCorrect ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          controller.wasCorrect
                              ? Icons.check_circle
                              : Icons.error,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          controller.wasCorrect
                              ? '¡Correcto! +${controller.pointsEarned} puntos'
                              : 'Incorrecto. +${controller.pointsEarned} puntos',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOptionsGrid(GameController controller, BuildContext context) {
    final options = controller.currentSlide!.options as List;
    
    // Si hay 4 opciones, mostramos en grid de 2x2
    if (options.length == 4) {
      return GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5, // Relación ancho/alto
        children: options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          final optionText = option.text ?? option.mediaId ?? 'Opción $index';
          final isSelected = selectedIndices.contains(index);
          final colorIndex = index % optionColors.length;

          return _buildOptionButton(
            index: index,
            text: optionText,
            color: optionColors[colorIndex],
            isSelected: isSelected,
            controller: controller,
          );
        }).toList(),
      );
    } else {
      // Si no hay exactamente 4 opciones, mostrar en lista
      return ListView.separated(
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final option = options[index];
          final optionText = option.text ?? option.mediaId ?? 'Opción $index';
          final isSelected = selectedIndices.contains(index);
          final colorIndex = index % optionColors.length;

          return _buildOptionButton(
            index: index,
            text: optionText,
            color: optionColors[colorIndex],
            isSelected: isSelected,
            controller: controller,
          );
        },
      );
    }
  }

  Widget _buildOptionButton({
    required int index,
    required String text,
    required Color color,
    required bool isSelected,
    required GameController controller,
  }) {
    return ElevatedButton(
      onPressed: controller.isSubmitting
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
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? color.withOpacity(0.9) : color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? Colors.black : Colors.transparent,
            width: isSelected ? 3 : 0,
          ),
        ),
        elevation: isSelected ? 4 : 2,
        shadowColor: Colors.black.withOpacity(0.2),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  void _submitAnswer(BuildContext context, GameController controller) async {
    final elapsedSeconds = startTime != null
        ? DateTime.now().difference(startTime!).inSeconds
        : 0;

    final answerEntity = Answer(
      slideId: controller.currentSlide!.slideId,
      answerIndex: selectedIndices.toList(),
      timeElapsedSeconds: elapsedSeconds,
    );
    
    await controller.submitAnswerResult(answerEntity, context);
    
    // Resetear para la siguiente pregunta
    setState(() {
      selectedIndices.clear();
      startTime = DateTime.now();
    });
  }
}