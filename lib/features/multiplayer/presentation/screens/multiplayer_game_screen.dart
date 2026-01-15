import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:green_frontend/features/multiplayer/presentation/bloc/multiplayer_bloc.dart';
import 'package:green_frontend/features/multiplayer/domain/value_objects/answer_id.dart';
import 'package:green_frontend/features/multiplayer/domain/value_objects/time_elapsed_ms.dart';
import 'package:green_frontend/features/multiplayer/presentation/screens/multiplayer_result_screen.dart';

class MultiplayerGameScreen extends StatelessWidget {
  const MultiplayerGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MultiplayerBloc, MultiplayerState>(
      listener: (context, state) {
        // Al terminar el tiempo, el server mandará un evento que cambie el estado
        if (state.status == MultiplayerStatus.showingResults) {
          Navigator.pushReplacement( // Usamos replacement para no volver atrás a la pregunta
      context,
      MaterialPageRoute(builder: (_) => const MultiplayerResultsScreen()),
    );
        }
      },
      builder: (context, state) {
        // Extraemos los datos del payload 'question_started'
        final slide = state.currentSlide; 
        final bool hasAnswered = state.hasAnswered;

        return Scaffold(
          backgroundColor: const Color(0xFFF2F2F2),
          body: SafeArea(
            child: Column(
              children: [
                // 1. Cronómetro y Progreso (Pág 64: timeRemainingMs)
                _buildHeader(state),

                // 2. Imagen y Pregunta (Pág 64: slideImageURL y questionText)
                Expanded(
                  flex: 3,
                  child: _buildQuestionArea(slide),
                ),

                // 3. Opciones de Respuesta (Pág 64: options[])
                Expanded(
                  flex: 4,
                  child: _buildOptionsGrid(context, slide, hasAnswered, state),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(MultiplayerState state) {
    // Cronómetro y progreso (Pág 64: timeRemainingMs)
    // Asumimos 30 segundos por pregunta
    const int totalTimeMs = 30000;
    final startTime = state.questionStartTime ?? DateTime.now();
    final elapsed = DateTime.now().difference(startTime).inMilliseconds;
    final remaining = totalTimeMs - elapsed;
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
                remaining > 10000 ? Colors.green : remaining > 5000 ? Colors.orange : Colors.red,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '${(remaining / 1000).ceil()}s',
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
        if (slide?.slideImageURL != null)
          Expanded(
            child: Image.network(slide!.slideImageURL, fit: BoxFit.contain),
          ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            slide?.questionText ?? "Cargando...",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildOptionsGrid(BuildContext context, dynamic slide, bool hasAnswered, MultiplayerState state) {
    final options = slide?.options ?? [];
    
    // Colores clásicos de Kahoot para las opciones
    final List<Color> colors = [Colors.red, Colors.blue, Colors.orange, Colors.green];

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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            // Si ya respondió, deshabilitamos visualmente
            elevation: hasAnswered ? 0 : 4,
          ),
          // Bloqueamos el click si ya respondió o si es el Host
          onPressed: hasAnswered 
            ? null 
            : () => _submitAnswer(context, state, option.index),
          child: Text(
            option.text,
            style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }

 void _submitAnswer(BuildContext context, MultiplayerState state, int optionIndex) {
  // 1. Obtenemos el ID de la pregunta
  final String qId = state.currentSlide?.id ?? "";

  // 2. Calculamos el tiempo
  final startTime = state.questionStartTime ?? DateTime.now();
  final int elapsed = DateTime.now().difference(startTime).inMilliseconds;

  // 3. Enviamos el evento usando tus Value Objects
  context.read<MultiplayerBloc>().add(
    OnSubmitAnswer(
      questionId: qId,
      // Usamos tus Value Objects definidos en los imports
      answerIds: AnswerIds([optionIndex.toString()]), 
      timeElapsedMs: TimeElapsedMs(elapsed),
    ),
  );
}

}