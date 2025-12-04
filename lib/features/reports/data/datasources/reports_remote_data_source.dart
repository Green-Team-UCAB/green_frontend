import '../models/report_summary_model.dart';
import '../models/report_detail_model.dart';
import '../models/session_report_model.dart';

abstract class ReportsRemoteDataSource {
  Future<List<ReportSummaryModel>> getMyResults();
  Future<ReportDetailModel> getReportDetail(String id);

  // ✅ MÉTODO QUE FALTABA EN LA INTERFAZ:
  Future<SessionReportModel> getSessionReport(String sessionId);
}

class ReportsRemoteDataSourceImpl implements ReportsRemoteDataSource {
  @override
  Future<List<ReportSummaryModel>> getMyResults() async {
    await Future.delayed(const Duration(milliseconds: 800));

    return [
      ReportSummaryModel(
        kahootId: '1',
        gameId: 'game-1',
        gameType: 'Multiplayer',
        title: 'Palabreando - Vocabulario',
        completionDate: DateTime.now().subtract(const Duration(hours: 2)),
        finalScore: 15400,
        rankingPosition: 1,
      ),
      ReportSummaryModel(
        kahootId: '2',
        gameId: 'game-2',
        gameType: 'Singleplayer',
        title: 'Matemáticas: Álgebra Lineal',
        completionDate: DateTime.now().subtract(const Duration(days: 1)),
        finalScore: 8500,
        rankingPosition: null,
      ),
      ReportSummaryModel(
        kahootId: '3',
        gameId: 'game-3',
        gameType: 'Multiplayer',
        title: 'Cultura General 2025',
        completionDate: DateTime.now().subtract(const Duration(days: 3)),
        finalScore: 12000,
        rankingPosition: 3,
      ),
      // Este es el item especial para probar H10.1
      ReportSummaryModel(
        kahootId: '99',
        gameId: 'session-host-1',
        gameType: 'Hosted',
        title: 'Torneo de Matemáticas (Anfitrión)',
        completionDate: DateTime.now().subtract(const Duration(days: 6)),
        finalScore: 0,
        rankingPosition: null,
      ),
    ];
  }

  @override
  Future<ReportDetailModel> getReportDetail(String id) async {
    await Future.delayed(const Duration(milliseconds: 600));

    // Lógica simplificada para el detalle de jugador (H10.3)
    return const ReportDetailModel(
      kahootId: '1',
      title: 'Palabreando - Vocabulario',
      finalScore: 15400,
      correctAnswers: 4,
      totalQuestions: 5,
      averageTimeMs: 4500,
      rankingPosition: 1,
      questions: [
        QuestionResultModel(
          questionIndex: 1,
          questionText: "¿Qué es un sinónimo?",
          isCorrect: true,
          timeTakenMs: 3200,
          answerText: ["Significado similar"],
        ),
        QuestionResultModel(
          questionIndex: 2,
          questionText: "Antónimo de 'Rápido'",
          isCorrect: false,
          timeTakenMs: 5100,
          answerText: ["Veloz"],
        ),
        QuestionResultModel(
          questionIndex: 3,
          questionText: "Sustantivo propio...",
          isCorrect: true,
          timeTakenMs: 2800,
          answerText: ["Perro"],
        ),
        QuestionResultModel(
          questionIndex: 4,
          questionText: "¿Cuál palabra es esdrújula?",
          isCorrect: true,
          timeTakenMs: 1500,
          answerText: ["Murciélago"],
        ),
        QuestionResultModel(
          questionIndex: 5,
          questionText: "Verbo en pasado de 'Comer'",
          isCorrect: true,
          timeTakenMs: 2100,
          answerText: ["Comió"],
        ),
      ],
    );
  }

  // ✅ IMPLEMENTACIÓN DEL NUEVO MÉTODO H10.1
  @override
  Future<SessionReportModel> getSessionReport(String sessionId) async {
    await Future.delayed(const Duration(milliseconds: 700));

    return SessionReportModel(
      reportId: 'rep-1',
      sessionId: sessionId,
      title: 'Torneo de Matemáticas - Resultados',
      executionDate: DateTime.now().subtract(const Duration(days: 6)),
      playerRanking: const [
        PlayerRankingModel(
          position: 1,
          username: "MariaGamer",
          score: 15000,
          correctAnswers: 10,
        ),
        PlayerRankingModel(
          position: 2,
          username: "JuanPerez",
          score: 14200,
          correctAnswers: 9,
        ),
        PlayerRankingModel(
          position: 3,
          username: "Luisa_99",
          score: 11000,
          correctAnswers: 7,
        ),
        PlayerRankingModel(
          position: 4,
          username: "Pedro",
          score: 8000,
          correctAnswers: 5,
        ),
        PlayerRankingModel(
          position: 5,
          username: "Invitado",
          score: 2000,
          correctAnswers: 1,
        ),
      ],
      questionAnalysis: const [
        QuestionAnalysisModel(
          questionIndex: 1,
          questionText: "2 + 2?",
          correctPercentage: 1.0,
        ),
        QuestionAnalysisModel(
          questionIndex: 2,
          questionText: "Raíz de 144",
          correctPercentage: 0.8,
        ),
        QuestionAnalysisModel(
          questionIndex: 3,
          questionText: "Derivada de e^x",
          correctPercentage: 0.4,
        ),
        QuestionAnalysisModel(
          questionIndex: 4,
          questionText: "Hipótesis de Riemann",
          correctPercentage: 0.0,
        ),
      ],
    );
  }
}
