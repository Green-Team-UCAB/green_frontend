import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/personal_report.dart';
import '../../domain/entities/report_summary.dart';
import '../../domain/entities/session_report.dart';
import '../../domain/repositories/reports_repository.dart';
import '../datasources/reports_remote_data_source.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsRemoteDataSource remoteDataSource;

  ReportsRepositoryImpl({required this.remoteDataSource});

  // ===========================================================================
  // 🎭 MOCK DATA FACTORY (DATOS FALSOS PARA PRUEBAS UI)
  // ===========================================================================

  // 1. LISTA DE HISTORIAL
  List<ReportSummary> _getMockSummaries() {
    return [
      ReportSummary(
        kahootId: 'k-host-1',
        gameId: 'session-123',
        gameType: 'Multiplayer_host',
        title: 'Examen Final de Matemáticas (Host)',
        completionDate: DateTime.now().subtract(const Duration(minutes: 30)),
        finalScore: null,
        rankingPosition: null,
      ),
      ReportSummary(
        kahootId: 'k-multi-1',
        gameId: 'session-456',
        gameType: 'Multiplayer_player',
        title: 'Trivia de Cultura General',
        completionDate: DateTime.now().subtract(const Duration(days: 1)),
        finalScore: 12500,
        rankingPosition: 3,
      ),
      ReportSummary(
        kahootId: 'k-single-1',
        gameId: 'attempt-789',
        gameType: 'Singleplayer',
        title: 'Práctica de Inglés Básico',
        completionDate: DateTime.now().subtract(const Duration(days: 2)),
        finalScore: 8400,
        rankingPosition: null,
      ),
    ];
  }

  // 2. REPORTE DE SESIÓN (VISTA ADMIN / HOST)
  SessionReport _getMockSessionReport(String sessionId) {
    return SessionReport(
      sessionId: sessionId,
      title: 'Reporte: Examen Final de Matemáticas',
      executionDate: DateTime.now(),
      playerRanking: [
        const PlayerRankingItem(
          position: 1,
          username: "Maria_Pro",
          score: 15000,
          correctAnswers: 10,
        ),
        const PlayerRankingItem(
          position: 2,
          username: "Juan_Gamer",
          score: 14200,
          correctAnswers: 9,
        ),
      ],
      questionAnalysis: [
        const QuestionAnalysisItem(
          questionIndex: 0,
          questionText: "¿Cuánto es 2 + 2?",
          correctPercentage: 0.95,
        ),
        const QuestionAnalysisItem(
          questionIndex: 1,
          questionText: "¿Capital de Australia?",
          correctPercentage: 0.45,
        ),
      ],
    );
  }

  // 3. REPORTE PERSONAL (VISTA JUGADOR)
  PersonalReport _getMockPersonalReport() {
    return PersonalReport(
      kahootId: 'k-1',
      title: 'Detalle de Resultados (Mock)',
      userId: 'u-1',
      finalScore: 12500,
      correctAnswers: 3,
      totalQuestions: 5,
      averageTimeMs: 5200,
      rankingPosition: 3,
      questionResults: [
        const QuestionResultItem(
          questionIndex: 0,
          questionText: "¿Cuál es el planeta rojo?",
          isCorrect: true,
          timeTakenMs: 2500,
          answerTexts: ["Marte"],
          answerMediaIds: [],
        ),
        const QuestionResultItem(
          questionIndex: 1,
          questionText: "¿Qué logo es este?",
          isCorrect: false,
          timeTakenMs: 4000,
          answerTexts: [],
          answerMediaIds: ["https://via.placeholder.com/150"], // URL dummy
        ),
      ],
    );
  }

  // ===========================================================================
  // ⚙️ LOGICA DEL REPOSITORIO (TRY API -> CATCH -> MOCK)
  // ===========================================================================

  Future<Either<Failure, T>> _execute<T>(
    Future<T> Function() call,
    T Function() mockFallback,
  ) async {
    try {
      final result = await call();
      return Right(result);
    } catch (e) {
      // En producción podrías usar 'log' en vez de print
      // print("⚠️ [ReportsRepo] Falló la API ($e). Usando MOCK DATA.");
      return Right(mockFallback());
    }
  }

  @override
  Future<Either<Failure, List<ReportSummary>>> getMyReportSummaries({
    int page = 1,
    int limit = 20,
  }) {
    return _execute(
      () => remoteDataSource.getMyReportSummaries(page: page, limit: limit),
      () => _getMockSummaries(),
    );
  }

  @override
  Future<Either<Failure, SessionReport>> getSessionReport(String sessionId) {
    return _execute(
      () => remoteDataSource.getSessionReport(sessionId),
      () => _getMockSessionReport(sessionId),
    );
  }

  @override
  Future<Either<Failure, PersonalReport>> getMultiplayerResult(
    String sessionId,
  ) {
    return _execute(
      () => remoteDataSource.getMultiplayerResult(sessionId),
      () => _getMockPersonalReport(),
    );
  }

  @override
  Future<Either<Failure, PersonalReport>> getSingleplayerResult(
    String attemptId,
  ) {
    return _execute(
      () => remoteDataSource.getSingleplayerResult(attemptId),
      () => _getMockPersonalReport(),
    );
  }
}
