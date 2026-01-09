part of 'reports_bloc.dart';

abstract class ReportsEvent extends Equatable {
  const ReportsEvent();

  @override
  List<Object> get props => [];
}

// Cargar historial de resultados (Lista inicial)
class LoadReportsHistoryEvent extends ReportsEvent {
  final int page;
  const LoadReportsHistoryEvent({this.page = 1});
}

// Cargar el detalle de un reporte específico
class LoadReportDetailEvent extends ReportsEvent {
  final String gameId; // attemptId o sessionId
  final String gameType; // "Singleplayer" | "Multiplayer" | "Host"

  const LoadReportDetailEvent({required this.gameId, required this.gameType});

  @override
  List<Object> get props => [gameId, gameType];
}
