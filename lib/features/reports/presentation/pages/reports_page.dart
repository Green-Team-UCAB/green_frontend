import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../injection_container.dart';
import '../../domain/entities/report_summary.dart';
import '../bloc/reports_bloc.dart';
import 'report_detail_page.dart';
import 'host_report_page.dart';

// PAGE
class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<ReportsBloc>()..add(const LoadReportsHistoryEvent()),
      child: const ReportsView(),
    );
  }
}

// VIEW
class ReportsView extends StatelessWidget {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Mis Informes'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        // automaticallyImplyLeading: false, // Descomentar si es pantalla raíz del navbar
      ),
      body: BlocBuilder<ReportsBloc, ReportsState>(
        builder: (context, state) {
          if (state is ReportsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ReportsLoaded) {
            if (state.reports.isEmpty) {
              return const Center(
                child: Text('Aún no has jugado ningún Kahoot.'),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<ReportsBloc>().add(
                  const LoadReportsHistoryEvent(),
                );
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.reports.length,
                separatorBuilder: (c, i) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final report = state.reports[index];

                  return GestureDetector(
                    onTap: () {
                      // Lógica para Anfitrión
                      if (report.gameType == 'Hosted' ||
                          report.gameType == 'Host') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                HostReportPage(sessionId: report.gameId),
                          ),
                        );
                      } else {
                        // Lógica para Jugador (Singleplayer / Multiplayer)
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReportDetailPage(
                              reportId: report.gameId,
                              gameType: report.gameType,
                            ),
                          ),
                        );
                      }
                    },
                    child: _ReportCard(report: report),
                  );
                },
              ),
            );
          } else if (state is ReportsError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// WIDGET: Tarjeta Estilizada
class _ReportCard extends StatelessWidget {
  final ReportSummary report;

  const _ReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    // Formato de fecha seguro
    String dateStr;
    try {
      dateStr = DateFormat(
        'dd/MM/yyyy, hh:mm a',
        'es',
      ).format(report.completionDate);
    } catch (e) {
      dateStr = 'Fecha inválida';
    }

    // Estilos según tipo de juego
    final isHost = report.gameType == 'Hosted' || report.gameType == 'Host';
    final isMultiplayer = report.gameType == 'Multiplayer';

    // Color distintivo para cada tipo
    Color cardColor = Colors.deepPurple; // Singleplayer por defecto
    if (isHost) {
      cardColor = Colors.orange[800]!;
    } else if (isMultiplayer) {
      cardColor = Colors.indigo;
    }

    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateStr,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    report.gameType.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              report.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (isHost) ...[
                  const Icon(Icons.people, color: Colors.white, size: 20),
                  const SizedBox(width: 4),
                  const Text(
                    'Ver Resultados',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ] else ...[
                  const Icon(Icons.stars, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '${report.finalScore} pts',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],

                const Spacer(),

                if (report.rankingPosition != null &&
                    report.rankingPosition! > 0) ...[
                  const Icon(Icons.emoji_events, color: Colors.white, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '#${report.rankingPosition}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
