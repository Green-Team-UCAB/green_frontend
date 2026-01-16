import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:green_frontend/features/multiplayer/presentation/bloc/multiplayer_bloc.dart';
import 'package:green_frontend/features/multiplayer/domain/value_objects/answer_id.dart';
import 'package:green_frontend/features/multiplayer/domain/value_objects/time_elapsed_ms.dart';
import 'package:green_frontend/features/multiplayer/presentation/screens/multiplayer_result_screen.dart';

class MultiplayerGameScreen extends StatefulWidget {
  const MultiplayerGameScreen({super.key});

  @override
  State<MultiplayerGameScreen> createState() => _MultiplayerGameScreenState();
}

class _MultiplayerGameScreenState extends State<MultiplayerGameScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Actualiza la UI cada 100ms para que la barra de tiempo baje suavemente.

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer
        ?.cancel(); // Limpiamos el timer al salir para evitar fugas de memoria
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MultiplayerBloc, MultiplayerState>(
      listener: (context, state) {
        // Navegación a resultados cuando termina la pregunta
        if (state.status == MultiplayerStatus.showingResults) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MultiplayerResultsScreen()),
          );
        }
      },
      builder: (context, state) {
        final slide = state.currentSlide;

        // Protección contra nulos
        if (slide == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF2F2F2),
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(state),

                // Expanded para la imagen/pregunta
                Expanded(
                  flex: 3,
                  child: _buildQuestionArea(slide),
                ),

                //  Expanded para los botones
                Expanded(
                  flex: 4,
                  child: _buildOptionsGrid(context, slide, state),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(MultiplayerState state) {
    const int totalTimeMs = 30000;
    final startTime = state.questionStartTime ?? DateTime.now();

    // Calculamos el tiempo transcurrido en tiempo real
    final elapsed = DateTime.now().difference(startTime).inMilliseconds;
    final remaining = totalTimeMs - elapsed;

    // Clamp para que no baje de 0.0 ni suba de 1.0
    final progress = (remaining / totalTimeMs).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                remaining > 10000
                    ? Colors.green
                    : remaining > 5000
                        ? Colors.orange
                        : Colors.red,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '${(remaining / 1000).ceil().clamp(0, 99)}s',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionArea(dynamic slide) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (slide.slideImageUrl != null && slide.slideImageUrl!.isNotEmpty)
          SizedBox(
            height: 180,
            child: Image.network(
              slide.slideImageUrl!,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.image_not_supported,
                  size: 50,
                  color: Colors.grey),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            slide.questionText,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildOptionsGrid(
      BuildContext context, dynamic slide, MultiplayerState state) {
    final options = slide.options;
    final hasAnswered = state.hasAnswered;

    final List<Color> colors = [
      Colors.red,
      Colors.blue,
      Colors.orange,
      Colors.green
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final option = options[index];

        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colors[index % colors.length],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            // Si ya respondió, quitamos la elevación para feedback visual
            elevation: hasAnswered ? 0 : 4,
            //  Cambiar opacidad si ya respondió
            foregroundColor:
                hasAnswered ? Colors.white.withOpacity(0.5) : Colors.white,
          ),
          onPressed: hasAnswered
              ? null // Deshabilita el botón si ya respondió
              : () => _submitAnswer(context, state, option.index),
          child: Text(
            option.text,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }

  void _submitAnswer(
      BuildContext context, MultiplayerState state, int optionIndex) {
    final String qId = state.currentSlide?.id ?? "";

    final startTime = state.questionStartTime ?? DateTime.now();
    final int elapsed = DateTime.now().difference(startTime).inMilliseconds;

    context.read<MultiplayerBloc>().add(
          OnSubmitAnswer(
            questionId: qId,
            answerIds: AnswerIds([optionIndex.toString()]),
            timeElapsedMs: TimeElapsedMs(elapsed),
          ),
        );
  }
}
