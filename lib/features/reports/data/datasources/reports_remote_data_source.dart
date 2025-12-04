import '../models/report_summary_model.dart';

abstract class ReportsRemoteDataSource {
  Future<List<ReportSummaryModel>> getMyResults();
}

class ReportsRemoteDataSourceImpl implements ReportsRemoteDataSource {
  @override
  Future<List<ReportSummaryModel>> getMyResults() async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 800));

    // Datos falsos basados en tu foto pero con datos de Jugador (según API)
    return [
      ReportSummaryModel(
        kahootId: '1',
        gameId: 'game-1',
        gameType: 'Multiplayer',
        title: 'Palabreando - Vocabulario',
        completionDate: DateTime.now().subtract(const Duration(hours: 2)),
        finalScore: 15400,
        rankingPosition: 1, // ¡Ganaste!
      ),
      ReportSummaryModel(
        kahootId: '2',
        gameId: 'game-2',
        gameType: 'Singleplayer',
        title: 'Matemáticas: Álgebra Lineal',
        completionDate: DateTime.now().subtract(const Duration(days: 1)),
        finalScore: 8500,
        rankingPosition: null, // Singleplayer no tiene ranking
      ),
      ReportSummaryModel(
        kahootId: '3',
        gameId: 'game-3',
        gameType: 'Multiplayer',
        title: 'Cultura General 2025',
        completionDate: DateTime.now().subtract(const Duration(days: 3)),
        finalScore: 12000,
        rankingPosition: 3, // Tercer puesto
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
    ];
  }
}
