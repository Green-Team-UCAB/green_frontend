import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:green_frontend/features/multiplayer/presentation/bloc/multiplayer_bloc.dart';
import 'package:green_frontend/features/multiplayer/domain/value_objects/answer_id.dart';
import 'package:green_frontend/features/multiplayer/domain/value_objects/time_elapsed_ms.dart';
import 'package:green_frontend/features/multiplayer/presentation/screens/multiplayer_result_screen.dart';
import 'package:green_frontend/features/multiplayer/domain/entities/slide.dart';

class MultiplayerGameScreen extends StatefulWidget {
  const MultiplayerGameScreen({super.key});

  @override
  State<MultiplayerGameScreen> createState() => _MultiplayerGameScreenState();
}

class _MultiplayerGameScreenState extends State<MultiplayerGameScreen> {
  int? selectedIndex;

  final List<Color> optionColors = const [
    Colors.blue,
    Colors.red,
    Colors.orange,
    Colors.green,
  ];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MultiplayerBloc, MultiplayerState>(
      listener: (context, state) {
        if (state.status == MultiplayerStatus.showingResults) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const MultiplayerResultsScreen(),
            ),
          );
        }
      },
      builder: (context, state) {
        final Slide? slide = state.currentSlide;

        if (slide == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(state, slide),

                Expanded(
                  flex: 3,
                  child: _buildQuestionArea(slide),
                ),

                Expanded(
                  flex: 4,
                  child: _buildOptionsGrid(context, slide, state),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                  child: _buildSubmitButton(context, state, slide.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // HEADER (TIMER)
  // ---------------------------------------------------------------------------

  Widget _buildHeader(MultiplayerState state, Slide slide) {
    final int totalTimeMs = slide.timeLimitSeconds * 1000;
    final startTime = state.questionStartTime ?? DateTime.now();
    final elapsed = DateTime.now().difference(startTime).inMilliseconds;
    final remaining = (totalTimeMs - elapsed).clamp(0, totalTimeMs);
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

  // ---------------------------------------------------------------------------
  // QUESTION AREA
  // ---------------------------------------------------------------------------

  Widget _buildQuestionArea(Slide slide) {
    final imageUrl = slide.slideImageUrl;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (imageUrl != null && imageUrl.isNotEmpty)
            SizedBox(
              height: 180,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.broken_image, size: 80),
                ),
              ),
            ),
          const SizedBox(height: 16),
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
    );
  }

  // ---------------------------------------------------------------------------
  // OPTIONS GRID
  // ---------------------------------------------------------------------------

  Widget _buildOptionsGrid(
    BuildContext context,
    Slide slide,
    MultiplayerState state,
  ) {
    final options = slide.options;
    final hasAnswered = state.hasAnswered;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 250,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final option = options[index];
        final isSelected = selectedIndex == index;
        final color = optionColors[index % optionColors.length];

        return GestureDetector(
          onTap: hasAnswered
              ? null
              : () {
                  setState(() => selectedIndex = index);
                },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? color : color.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Center(
              child: Text(
                option.text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // SUBMIT BUTTON
  // ---------------------------------------------------------------------------

  Widget _buildSubmitButton(
    BuildContext context,
    MultiplayerState state,
    String slideId,
  ) {
    final hasAnswered = state.hasAnswered;

    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 113, 7, 146),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: (selectedIndex == null || hasAnswered)
            ? null
            : () {
                final startTime = state.questionStartTime ?? DateTime.now();
                final elapsed =
                    DateTime.now().difference(startTime).inMilliseconds;

                // 🔥 Aquí convertimos el índice a String para AnswerIds
                final answerId = selectedIndex!.toString();

                context.read<MultiplayerBloc>().add(
                      OnSubmitAnswer(
                        questionId: slideId,
                        answerIds: AnswerIds([answerId]),
                        timeElapsedMs: TimeElapsedMs(elapsed),
                      ),
                    );
              },
        child: const Text(
          "ENVIAR RESPUESTA",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}