import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../bloc/reports_bloc.dart';
import '../../domain/entities/personal_report.dart';

// PAGE
class ReportDetailPage extends StatelessWidget {
  final String reportId;
  final String gameType; // 'Singleplayer' | 'Multiplayer'

  const ReportDetailPage({
    super.key,
    required this.reportId,
    required this.gameType,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<ReportsBloc>()
            ..add(LoadReportDetailEvent(gameId: reportId, gameType: gameType)),
      child: const ReportDetailView(),
    );
  }
}

// VIEW
class ReportDetailView extends StatelessWidget {
  const ReportDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Resumen'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: BlocBuilder<ReportsBloc, ReportsState>(
        builder: (context, state) {
          if (state is ReportDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PersonalReportLoaded) {
            return _buildContent(context, state.report);
          } else if (state is ReportDetailError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, PersonalReport report) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Resumen General (Ranking, Puntos, Aciertos)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  report.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    if (report.rankingPosition != null)
                      _ScoreBadge(
                        icon: Icons.emoji_events,
                        label: 'Ranking',
                        value: '#${report.rankingPosition}',
                      ),
                    _ScoreBadge(
                      icon: Icons.star,
                      label: 'Puntos',
                      value: '${report.finalScore}',
                    ),
                    _ScoreBadge(
                      icon: Icons.check_circle,
                      label: 'Aciertos',
                      value:
                          '${report.correctAnswers}/${report.totalQuestions}',
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Desglose por pregunta",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),

          // Lista de Preguntas
          ...report.questionResults.map(
            (q) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: q.isCorrect
                            ? Colors.green[100]
                            : Colors.red[100],
                        child: Icon(
                          q.isCorrect ? Icons.check : Icons.close,
                          color: q.isCorrect ? Colors.green : Colors.red,
                        ),
                      ),
                      title: Text(
                        q.questionText,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        "${(q.timeTakenMs / 1000).toStringAsFixed(1)}s",
                      ),
                    ),

                    // LÓGICA DE RESPUESTAS (TEXTO O IMAGEN)
                    if (q.answerTexts.isNotEmpty || q.answerMediaIds.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 4,
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Tu respuesta:",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // RESPUESTAS DE TEXTO
                              if (q.answerTexts.isNotEmpty)
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: q.answerTexts
                                      .map(
                                        (text) => Chip(
                                          label: Text(
                                            text,
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                          backgroundColor: Colors.white,
                                          elevation: 1,
                                          visualDensity: VisualDensity.compact,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                            side: BorderSide(
                                              color: Colors.grey[300]!,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),

                              // RESPUESTAS DE IMAGEN
                              if (q.answerMediaIds.isNotEmpty)
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: q.answerMediaIds
                                      .map(
                                        (url) => Container(
                                          width: 100,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey[300]!,
                                            ),
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                url,
                                              ), // Asume URL válida
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                            ],
                          ),
                        ),
                      )
                    else
                      // SIN RESPUESTA
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Sin respuesta / Tiempo agotado",
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ScoreBadge({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }
}
