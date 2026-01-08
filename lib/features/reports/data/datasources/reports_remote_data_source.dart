import '../models/report_summary_model.dart';
import '../models/report_detail_model.dart';
import '../models/session_report_model.dart';
import 'package:http/http.dart' as http;

abstract class ReportsRemoteDataSource {
  Future<List<ReportSummaryModel>> getMyResults();
  Future<ReportDetailModel> getReportDetail(String id);
  Future<SessionReportModel> getSessionReport(String sessionId);
}

class ReportsRemoteDataSourceImpl implements ReportsRemoteDataSource {
  final http.Client client;

  ReportsRemoteDataSourceImpl({required this.client});

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
      ReportSummaryModel(
        kahootId: '4',
        gameId: 'game-4',
        gameType: 'Multiplayer',
        title: 'Historia de Roma',
        completionDate: DateTime.now().subtract(const Duration(days: 5)),
        finalScore: 4000,
        rankingPosition: 15,
      ),
      // Item para probar H10.1 (Anfitrión)
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

    // CASO 1: Palabreando (Con Multiple Choice)
    if (id == 'game-1') {
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
            answerText: ["Significado similar", "Parecido"],
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
    // CASO 2: Matemáticas
    else if (id == 'game-2') {
      return const ReportDetailModel(
        kahootId: '2',
        title: 'Matemáticas: Álgebra Lineal',
        finalScore: 8500,
        correctAnswers: 2,
        totalQuestions: 4,
        averageTimeMs: 12000,
        rankingPosition: null,
        questions: [
          QuestionResultModel(
            questionIndex: 1,
            questionText: "Resolver: 2x + 4 = 10",
            isCorrect: true,
            timeTakenMs: 5000,
            answerText: ["3"],
          ),
          QuestionResultModel(
            questionIndex: 2,
            questionText: "Derivada de x^2",
            isCorrect: true,
            timeTakenMs: 8000,
            answerText: ["2x"],
          ),
          QuestionResultModel(
            questionIndex: 3,
            questionText: "Integral de 1/x",
            isCorrect: false,
            timeTakenMs: 15000,
            answerText: ["-1/x^2"],
          ),
          QuestionResultModel(
            questionIndex: 4,
            questionText: "Valor de Pi",
            isCorrect: false,
            timeTakenMs: 12000,
            answerText: [],
          ),
        ],
      );
    }
    // CASO 3: Cultura General (Con Imagen)
    else if (id == 'game-3') {
      return const ReportDetailModel(
        kahootId: '3',
        title: 'Cultura General 2025',
        finalScore: 12000,
        correctAnswers: 3,
        totalQuestions: 3,
        averageTimeMs: 3000,
        rankingPosition: 3,
        questions: [
          QuestionResultModel(
            questionIndex: 1,
            questionText: "¿Capital de Australia?",
            isCorrect: true,
            timeTakenMs: 2000,
            answerText: ["Canberra"],
          ),
          QuestionResultModel(
            questionIndex: 2,
            questionText: "¿Quién pintó la Mona Lisa?",
            isCorrect: true,
            timeTakenMs: 1800,
            answerText: [],
            answerImages: [
              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRTJibBNBf1wrC0PZmHX5MaQXSz_rjfPlt1uP1iRND6uDfBTVQCA4y4TSU5alkY3prlm-Pn3Knpp1WLwrrygKfsrdcgkSjRIaMQP_MAJ225&s=10",
            ],
          ),
          QuestionResultModel(
            questionIndex: 3,
            questionText: "¿Símbolo químico del Oxígeno?",
            isCorrect: true,
            timeTakenMs: 1500,
            answerText: ["O"],
          ),
        ],
      );
    }
    // CASO 4: Historia de Roma
    else if (id == 'game-4') {
      return const ReportDetailModel(
        kahootId: '4',
        title: 'Historia de Roma',
        finalScore: 4000,
        correctAnswers: 1,
        totalQuestions: 3,
        averageTimeMs: 6000,
        rankingPosition: 15,
        questions: [
          QuestionResultModel(
            questionIndex: 1,
            questionText: "¿Quién fundó Roma?",
            isCorrect: true,
            timeTakenMs: 4000,
            answerText: ["Rómulo y Remo"],
          ),
          QuestionResultModel(
            questionIndex: 2,
            questionText: "¿Primer emperador?",
            isCorrect: false,
            timeTakenMs: 7000,
            answerText: ["Julio César"],
          ),
          QuestionResultModel(
            questionIndex: 3,
            questionText: "Año de la caída del imperio",
            isCorrect: false,
            timeTakenMs: 5500,
            answerText: ["1492"],
          ),
        ],
      );
    }

    // DEFAULT
    return const ReportDetailModel(
      kahootId: '0',
      title: 'Reporte no encontrado',
      finalScore: 0,
      correctAnswers: 0,
      totalQuestions: 0,
      averageTimeMs: 0,
      rankingPosition: 0,
      questions: [],
    );
  }

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
