import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/session_report.dart';
import '../bloc/reports_bloc.dart'; // Usamos el BLoC unificado

// PAGE
class HostReportPage extends StatelessWidget {
  final String sessionId;

  const HostReportPage({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<ReportsBloc>()
            ..add(LoadReportDetailEvent(gameId: sessionId, gameType: 'Host')),
      child: const HostReportView(),
    );
  }
}

// VIEW
class HostReportView extends StatelessWidget {
  const HostReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Resultados de Sesión'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocBuilder<ReportsBloc, ReportsState>(
        builder: (context, state) {
          if (state is ReportDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SessionReportLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.report.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Jugado el ${state.report.executionDate.day}/${state.report.executionDate.month}/${state.report.executionDate.year}",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    "Tabla de posiciones",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _LeaderboardCard(players: state.report.playerRanking),

                  const SizedBox(height: 24),
                  const Text(
                    "Exactitud de la pregunta",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "Barras rojas indican preguntas difíciles (<50% aciertos)",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  _QuestionAnalysisList(
                    questions: state.report.questionAnalysis,
                  ),
                ],
              ),
            );
          } else if (state is ReportDetailError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _LeaderboardCard extends StatelessWidget {
  final List<PlayerRankingItem> players; // Usamos la entidad definida en domain

  const _LeaderboardCard({required this.players});

  @override
  Widget build(BuildContext context) {
    if (players.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text("No hay jugadores en el ranking."),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: players.map((player) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: _getRankColor(player.position),
              foregroundColor: player.position <= 3
                  ? Colors.white
                  : Colors.black54,
              child: Text("${player.position}"),
            ),
            title: Text(
              player.username,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: Text(
              "${player.score} pts",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getRankColor(int position) {
    if (position == 1) return Colors.amber;
    if (position == 2) return Colors.grey;
    if (position == 3) return Colors.brown;
    return Colors.grey[200]!;
  }
}

class _QuestionAnalysisList extends StatelessWidget {
  final List<QuestionAnalysisItem> questions;

  const _QuestionAnalysisList({required this.questions});

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return const Text("No hay datos de preguntas disponibles.");
    }

    return Column(
      children: questions.map((q) {
        final percentage = (q.correctPercentage * 100).toInt();
        Color barColor = Colors.green;
        if (q.correctPercentage < 0.5) {
          barColor = Colors.redAccent;
        } else if (q.correctPercentage < 0.8) {
          barColor = Colors.orangeAccent;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  q.questionText,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: q.correctPercentage,
                          color: barColor,
                          backgroundColor: Colors.grey[200],
                          minHeight: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "$percentage%",
                      style: TextStyle(
                        color: barColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  percentage < 50 ? "Pregunta difícil" : "Bien contestada",
                  style: TextStyle(fontSize: 12, color: barColor),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
