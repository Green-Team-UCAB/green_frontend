import '../../../../core/network/api_client.dart';
import '../models/report_summary_model.dart';
import '../models/session_report_model.dart';
import '../models/personal_report_model.dart';

abstract class ReportsRemoteDataSource {
  Future<List<ReportSummaryModel>> getMyReportSummaries({
    int page = 1,
    int limit = 20,
  });
  Future<SessionReportModel> getSessionReport(String sessionId);
  Future<PersonalReportModel> getMultiplayerResult(String sessionId);
  Future<PersonalReportModel> getSingleplayerResult(String attemptId);
}

class ReportsRemoteDataSourceImpl implements ReportsRemoteDataSource {
  final ApiClient apiClient;

  ReportsRemoteDataSourceImpl({required this.apiClient});

  // --- HELPER PRIVADO LIMPIO ---
  // ⚠️ CLAVE DEL ÉXITO: NO creamos 'Options' aquí.
  // Usamos las que ApiClient ya tiene configuradas globalmente.
  Future<T> _get<T>({
    required String path,
    Map<String, dynamic>? queryParams,
    required T Function(dynamic data) parser,
  }) async {
    // LLAMADA LIMPIA: Sin parámetro 'options'
    final response = await apiClient.get(
      path: path,
      queryParameters: queryParams,
    );

    return parser(response.data);
  }

  // --- IMPLEMENTACIÓN ---

  @override
  Future<List<ReportSummaryModel>> getMyReportSummaries({
    int page = 1,
    int limit = 20,
  }) {
    return _get(
      path: '/reports/kahoots/my-results',
      queryParams: {'page': page, 'limit': limit},
      parser: (data) {
        final list = (data is Map && data['results'] is List)
            ? data['results']
            : [];
        return (list as List)
            .map((e) => ReportSummaryModel.fromJson(e))
            .toList();
      },
    );
  }

  @override
  Future<SessionReportModel> getSessionReport(String sessionId) {
    return _get(
      path: '/reports/sessions/$sessionId',
      parser: (data) => SessionReportModel.fromJson(data),
    );
  }

  @override
  Future<PersonalReportModel> getMultiplayerResult(String sessionId) {
    return _get(
      path: '/reports/multiplayer/$sessionId',
      parser: (data) => PersonalReportModel.fromJson(data),
    );
  }

  @override
  Future<PersonalReportModel> getSingleplayerResult(String attemptId) {
    return _get(
      path: '/reports/singleplayer/$attemptId',
      parser: (data) => PersonalReportModel.fromJson(data),
    );
  }
}
