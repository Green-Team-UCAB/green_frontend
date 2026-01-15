import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Use Cases
import '../../application/get_my_reports_use_case.dart';
import '../../application/get_session_report_use_case.dart';
import '../../application/get_multiplayer_result_use_case.dart';
import '../../application/get_singleplayer_result_use_case.dart';

// Entities
import '../../domain/entities/report_summary.dart';
import '../../domain/entities/personal_report.dart';
import '../../domain/entities/session_report.dart';

part 'reports_event.dart';
part 'reports_state.dart';

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final GetMyReportSummariesUseCase getMyReportSummariesUseCase;
  final GetSessionReportUseCase getSessionReportUseCase;
  final GetMultiplayerResultUseCase getMultiplayerResultUseCase;
  final GetSingleplayerResultUseCase getSingleplayerResultUseCase;

  ReportsBloc({
    required this.getMyReportSummariesUseCase,
    required this.getSessionReportUseCase,
    required this.getMultiplayerResultUseCase,
    required this.getSingleplayerResultUseCase,
  }) : super(ReportsInitial()) {
    // 1. CARGAR LISTA HISTORIAL
    on<LoadReportsHistoryEvent>((event, emit) async {
      emit(ReportsLoading());
      final result = await getMyReportSummariesUseCase(page: event.page);
      result.fold(
        (failure) => emit(ReportsError(failure.message)),
        (reports) => emit(ReportsLoaded(reports)),
      );
    });

    // 2. CARGAR DETALLE (ROUTER INTELIGENTE)
    on<LoadReportDetailEvent>((event, emit) async {
      emit(ReportDetailLoading());

      final type = event.gameType.trim();

      if (type == 'Multiplayer_host') {
        // --- CASO A: SOY EL HOST ---
        final result = await getSessionReportUseCase(event.gameId);
        result.fold(
          (failure) => emit(ReportDetailError(failure.message)),
          (report) => emit(SessionReportLoaded(report)),
        );
      } else if (type == 'Singleplayer') {
        // --- CASO B: JUGUÉ SOLO ---
        final result = await getSingleplayerResultUseCase(event.gameId);
        result.fold(
          (failure) => emit(ReportDetailError(failure.message)),
          (report) => emit(PersonalReportLoaded(report)),
        );
      } else if (type == 'Multiplayer_player') {
        // --- CASO C: JUGUÉ MULTIPLAYER (Como jugador) ---
        final result = await getMultiplayerResultUseCase(event.gameId);
        result.fold(
          (failure) => emit(ReportDetailError(failure.message)),
          (report) => emit(PersonalReportLoaded(report)),
        );
      } else {
        emit(ReportDetailError("Tipo de juego desconocido: $type"));
      }
    });
  }
}
