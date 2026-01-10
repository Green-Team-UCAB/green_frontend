import 'package:dartz/dartz.dart';
import 'dart:math'; // Para randoms si quisieras, aunque aquí usaremos datos fijos para probar casos específicos
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

  // 1. LISTA DE HISTORIAL (Muestra Host, Single y Multi)
  List<ReportSummary> _getMockSummaries() {
    return [
      ReportSummary(
        kahootId: 'k-host-1',
        gameId: 'session-123', // ID para el Host Report
        gameType: 'Hosted', // <--- CASO ADMIN/HOST
        title: 'Examen Final de Matemáticas (Host)',
        completionDate: DateTime.now().subtract(const Duration(minutes: 30)),
        finalScore: 0, // El host no tiene score propio
        rankingPosition: null,
      ),
      ReportSummary(
        kahootId: 'k-multi-1',
        gameId: 'session-456',
        gameType: 'Multiplayer', // <--- CASO JUGADOR MULTI
        title: 'Trivia de Cultura General',
        completionDate: DateTime.now().subtract(const Duration(days: 1)),
        finalScore: 12500,
        rankingPosition: 3, // Quedó 3ro
      ),
      ReportSummary(
        kahootId: 'k-single-1',
        gameId: 'attempt-789',
        gameType: 'Singleplayer', // <--- CASO SINGLE PLAYER
        title: 'Práctica de Inglés Básico',
        completionDate: DateTime.now().subtract(const Duration(days: 2)),
        finalScore: 8400,
        rankingPosition: null, // Single no tiene ranking vs otros
      ),
      ReportSummary(
        kahootId: 'k-multi-2',
        gameId: 'session-999',
        gameType: 'Multiplayer',
        title: 'Torneo de Programación',
        completionDate: DateTime.now().subtract(const Duration(days: 5)),
        finalScore: 4500,
        rankingPosition: 12, // Quedó lejos
      ),
    ];
  }

  // 2. REPORTE DE SESIÓN (VISTA ADMIN / HOST)
  SessionReport _getMockSessionReport(String sessionId) {
    return SessionReport(
      reportId: 'rep-host-001',
      sessionId: sessionId,
      title: 'Reporte: Examen Final de Matemáticas',
      executionDate: DateTime.now(),
      // TABLA DE POSICIONES (Ranking)
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
        const PlayerRankingItem(
          position: 3,
          username: "Tu Usuario",
          score: 12500,
          correctAnswers: 8,
        ), // Tú
        const PlayerRankingItem(
          position: 4,
          username: "Carlos123",
          score: 8000,
          correctAnswers: 5,
        ),
        const PlayerRankingItem(
          position: 5,
          username: "Ana_Bot",
          score: 4000,
          correctAnswers: 3,
        ),
      ],
      // ANÁLISIS DE PREGUNTAS (Barras de colores)
      questionAnalysis: [
        const QuestionAnalysisItem(
          questionIndex: 0,
          questionText: "¿Cuánto es 2 + 2?",
          correctPercentage: 0.95, // Verde (Muy fácil)
        ),
        const QuestionAnalysisItem(
          questionIndex: 1,
          questionText: "¿Cuál es la capital de Australia?",
          correctPercentage: 0.45, // Rojo (Difícil / Tramposa)
        ),
        const QuestionAnalysisItem(
          questionIndex: 2,
          questionText: "¿Fórmula del agua?",
          correctPercentage: 0.80, // Verde/Naranja
        ),
        const QuestionAnalysisItem(
          questionIndex: 3,
          questionText: "Derivada de x^2",
          correctPercentage: 0.60, // Naranja (Media)
        ),
        const QuestionAnalysisItem(
          questionIndex: 4,
          questionText: "¿Quién pintó la Mona Lisa?",
          correctPercentage: 0.20, // Rojo (Muy difícil)
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
        // CASO 1: Respuesta Correcta Texto Simple
        const QuestionResultItem(
          questionIndex: 0,
          questionText: "¿Cuál es el planeta rojo?",
          isCorrect: true,
          timeTakenMs: 2500,
          answerTexts: ["Marte"],
          answerMediaIds: [],
        ),
        // CASO 2: Respuesta Incorrecta
        const QuestionResultItem(
          questionIndex: 1,
          questionText: "¿Animal más rápido del mundo?",
          isCorrect: false,
          timeTakenMs: 8000,
          answerTexts: ["Leon"], // El usuario eligió mal
          answerMediaIds: [],
        ),
        // CASO 3: Respuesta con IMAGEN (Sin texto)
        const QuestionResultItem(
          questionIndex: 2,
          questionText: "¿Qué logo pertenece a Flutter?",
          isCorrect: true,
          timeTakenMs: 4000,
          answerTexts: [],
          // URL simulada de imagen
          answerMediaIds: [
            "https://storage.googleapis.com/cms-storage-bucket/0dbfcc7a59cd1cf16282.png",
          ],
        ),
        // CASO 4: Respuesta MULTIPLE (Dos opciones seleccionadas)
        const QuestionResultItem(
          questionIndex: 3,
          questionText: "¿Cuáles son colores primarios?",
          isCorrect: true,
          timeTakenMs: 6500,
          answerTexts: ["Rojo", "Azul"], // Usuario seleccionó dos
          answerMediaIds: [],
        ),
        // CASO 5: Respuesta Mixta o Vacía (Timeout)
        const QuestionResultItem(
          questionIndex: 4,
          questionText: "¿Pregunta difícil sin responder?",
          isCorrect: false,
          timeTakenMs: 30000,
          answerTexts: [],
          answerMediaIds: [],
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
      print("⚠️ [ReportsRepo] Falló la API ($e). Usando MOCK DATA.");
      // Simulamos un pequeño delay para que se vea el loading
      await Future.delayed(const Duration(milliseconds: 800));
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
