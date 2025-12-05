import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../bloc/report_detail_bloc.dart';
import '../../domain/entities/report_detail.dart';

// PAGE
class ReportDetailPage extends StatelessWidget {
  final String reportId;

  const ReportDetailPage({super.key, required this.reportId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<ReportDetailBloc>()..add(LoadReportDetailEvent(reportId)),
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
      body: BlocBuilder<ReportDetailBloc, ReportDetailState>(
        builder: (context, state) {
          if (state is ReportDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ReportDetailLoaded) {
            return _buildContent(context, state.report);
          } else if (state is ReportDetailError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, ReportDetail report) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Resumen General
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.circular(16),
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
                    _ScoreBadge(
                      icon: Icons.emoji_events,
                      label: 'Ranking',
                      value: '#${report.rankingPosition ?? "-"}',
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
          ...report.questions.map(
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

                    // SECCIÓN DE RESPUESTAS DEL USUARIO (Soporta Multiple Choice)
                    if ((q.answerText != null && q.answerText!.isNotEmpty) ||
                        (q.answerImages != null && q.answerImages!.isNotEmpty))
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
                                "Tu respuesta:", // El título singular funciona para 1 o varias
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // 1. Renderizar Texto (Wrap soporta múltiples elementos automáticamente)
                              if (q.answerText != null &&
                                  q.answerText!.isNotEmpty)
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: q.answerText!
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

                              // 2. Renderizar Imágenes Reales (Wrap soporta múltiples imágenes)
                              if (q.answerImages != null &&
                                  q.answerImages!.isNotEmpty)
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: q.answerImages!
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
                                              ), // Carga la imagen real
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
