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
        if (state.status == MultiplayerStatus.showingResults) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MultiplayerResultsScreen()),
          );
        }
      },
      builder: (context, state) {
        final slide = state.currentSlide;

        // 🔥 Evita crash si slide aún no ha llegado
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

                // 🔥 NO usar Expanded dentro de _buildQuestionArea
                Expanded(
                  flex: 3,
                  child: _buildQuestionArea(slide),
                ),

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
        if (slide?.slideImageUrl != null)
          SizedBox(
            height: 180, // 🔥 Tamaño fijo, NO Expanded
            child: Image.network(slide.slideImageUrl, fit: BoxFit.contain),
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
            elevation: hasAnswered ? 0 : 4,
          ),
          onPressed: hasAnswered
              ? null
              : () => _submitAnswer(context, state, option.index),
          child: Text(
            option.text,
            style: const TextStyle(
                fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }

  void _submitAnswer(
      BuildContext context, MultiplayerState state, String optionIndex) {
    final String qId = state.currentSlide?.id ?? "";

    final startTime = state.questionStartTime ?? DateTime.now();
    final int elapsed = DateTime.now().difference(startTime).inMilliseconds;

    context.read<MultiplayerBloc>().add(
          OnSubmitAnswer(
            questionId: qId,
            answerIds: AnswerIds([optionIndex]),
            timeElapsedMs: TimeElapsedMs(elapsed),
          ),
        );
  }
}