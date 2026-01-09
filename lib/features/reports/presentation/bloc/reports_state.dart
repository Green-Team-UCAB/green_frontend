part of 'reports_bloc.dart';

abstract class ReportsState extends Equatable {
  const ReportsState();

  @override
  List<Object?> get props => [];
}

class ReportsInitial extends ReportsState {}

// --- ESTADOS PARA LA LISTA (HISTORIAL) ---
class ReportsLoading extends ReportsState {}

class ReportsLoaded extends ReportsState {
  final List<ReportSummary> reports;
  const ReportsLoaded(this.reports);

  @override
  List<Object> get props => [reports];
}

class ReportsError extends ReportsState {
  final String message;
  const ReportsError(this.message);

  @override
  List<Object> get props => [message];
}

// --- ESTADOS PARA EL DETALLE ---
class ReportDetailLoading extends ReportsState {}

// Cuando carga un reporte personal (Jugador)
class PersonalReportLoaded extends ReportsState {
  final PersonalReport report;
  const PersonalReportLoaded(this.report);

  @override
  List<Object> get props => [report];
}

// Cuando carga un reporte de sesión (Host)
class SessionReportLoaded extends ReportsState {
  final SessionReport report;
  const SessionReportLoaded(this.report);

  @override
  List<Object> get props => [report];
}

class ReportDetailError extends ReportsState {
  final String message;
  const ReportDetailError(this.message);

  @override
  List<Object> get props => [message];
}
