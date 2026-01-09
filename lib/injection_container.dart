import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // Para debugPrint

// Core
import 'core/network/api_client.dart';
import 'core/storage/token_storage.dart';

// --- Feature: Discovery (H6.1) ---
import 'features/discovery/data/datasources/discovery_remote_data_source.dart';
import 'features/discovery/data/repositories/discovery_repository_impl.dart';
import 'features/discovery/domain/repositories/discovery_repository.dart';
import 'features/discovery/presentation/bloc/discovery_bloc.dart';

// --- Feature: Reports (Épica 10) ---
import 'features/reports/infrastructure/datasources/reports_remote_data_source.dart';
import 'features/reports/infrastructure/repositories/reports_repository_impl.dart';
import 'features/reports/domain/repositories/reports_repository.dart';
import 'features/reports/presentation/bloc/reports_bloc.dart';
import 'features/reports/application/get_my_reports_use_case.dart';
import 'features/reports/application/get_session_report_use_case.dart';
import 'features/reports/application/get_multiplayer_result_use_case.dart';
import 'features/reports/application/get_singleplayer_result_use_case.dart';

// --- Feature: Library (Épica 7) ---
import 'features/library/infrastructure/datasources/library_remote_datasource.dart';
import 'features/library/infrastructure/datasources/library_repository_impl.dart';
import 'features/library/domain/repositories/library_repository.dart';
import 'features/library/presentation/bloc/library_bloc.dart';
import 'features/library/application/get_my_kahoots_use_case.dart';
import 'features/library/application/get_favorites_use_case.dart';
import 'features/library/application/get_in_progress_use_case.dart';
import 'features/library/application/get_completed_use_case.dart';
import 'features/library/application/toggle_favorite_use_case.dart';

// --- Feature: Groups (Épica 8) ---
import 'features/groups/data/datasources/groups_remote_data_source.dart';
import 'features/groups/data/repositories/groups_repository_impl.dart';
import 'features/groups/domain/repositories/groups_repository.dart';
import 'features/groups/presentation/bloc/groups_bloc.dart';
import 'features/groups/presentation/bloc/detail/group_detail_bloc.dart';
import 'features/groups/presentation/bloc/settings/group_settings_bloc.dart';
import 'features/groups/presentation/bloc/selection/kahoot_selection_bloc.dart';

// Instancia global del Service Locator
final sl = GetIt.instance;

Future<void> init() async {
  // ================================================================
  // 1. FEATURES
  // ================================================================

  // --- Discovery (H6.1) ---
  sl.registerFactory(() => DiscoveryBloc(repository: sl()));

  sl.registerLazySingleton<DiscoveryRepository>(
    () => DiscoveryRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<DiscoveryRemoteDataSource>(
    () => DiscoveryRemoteDataSourceImpl(apiClient: sl()),
  );

  // --- Reports (Épica 10) ---
  // Use Cases
  sl.registerLazySingleton(() => GetMyReportSummariesUseCase(sl()));
  sl.registerLazySingleton(() => GetSessionReportUseCase(sl()));
  sl.registerLazySingleton(() => GetMultiplayerResultUseCase(sl()));
  sl.registerLazySingleton(() => GetSingleplayerResultUseCase(sl()));

  // Bloc
  sl.registerFactory(
    () => ReportsBloc(
      getMyReportSummariesUseCase: sl(),
      getSessionReportUseCase: sl(),
      getMultiplayerResultUseCase: sl(),
      getSingleplayerResultUseCase: sl(),
    ),
  );

  // Repository
  sl.registerLazySingleton<ReportsRepository>(
    () => ReportsRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Source
  sl.registerLazySingleton<ReportsRemoteDataSource>(
    () => ReportsRemoteDataSourceImpl(apiClient: sl()),
  );

  // --- Library (Épica 7) ---
  // Use Cases
  sl.registerLazySingleton(() => GetMyKahootsUseCase(sl()));
  sl.registerLazySingleton(() => GetFavoritesUseCase(sl()));
  sl.registerLazySingleton(() => GetInProgressUseCase(sl()));
  sl.registerLazySingleton(() => GetCompletedUseCase(sl()));
  sl.registerLazySingleton(() => ToggleFavoriteUseCase(sl()));

  // Bloc
  sl.registerFactory(
    () => LibraryBloc(
      getMyKahoots: sl(),
      getFavorites: sl(),
      getInProgress: sl(),
      getCompleted: sl(),
      toggleFavorite: sl(),
    ),
  );

  // Repository
  sl.registerLazySingleton<LibraryRepository>(
    () => LibraryRepositoryImpl(dataSource: sl()),
  );

  // Data Source
  sl.registerLazySingleton<LibraryRemoteDataSource>(
    () => LibraryRemoteDataSourceImpl(apiClient: sl()),
  );

  // --- Groups (Épica 8) ---
  sl.registerFactory(() => GroupsBloc(repository: sl()));
  sl.registerFactory(() => GroupDetailBloc(repository: sl()));
  sl.registerFactory(() => GroupSettingsBloc(repository: sl()));
  sl.registerFactory(() => KahootSelectionBloc(repository: sl()));

  // Repository
  sl.registerLazySingleton<GroupsRepository>(
    () => GroupsRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Source
  sl.registerLazySingleton<GroupsRemoteDataSource>(
    () => GroupsRemoteDataSourceImpl(apiClient: sl()),
  );

  // ================================================================
  // 2. CORE & EXTERNAL
  // ================================================================

  // Dio Base Configuration
  sl.registerLazySingleton(
    () => Dio(
      BaseOptions(
        baseUrl: 'https://quizzy-backend-0wh2.onrender.com/api',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    ),
  );

  // ApiClient Wrapper (Singleton)
  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl()));

  // Http Client (usado por themes, si aplica)
  sl.registerLazySingleton<http.Client>(() => http.Client());

  // ================================================================
  // 3. INICIALIZACIÓN DE SESIÓN (SOLUCIÓN 401)
  // ================================================================
  try {
    // Leemos el token usando el Helper que configuramos (busca 'auth_token' o 'accessToken')
    final token = await TokenStorage.getToken();

    if (token != null && token.isNotEmpty) {
      // ✅ Inyectamos el token en ApiClient para que TODAS las features lo usen automáticamente
      sl<ApiClient>().setAuthToken(token);
      debugPrint(
        "✅ INJECTION: Token cargado y seteado en ApiClient globalmente.",
      );
    } else {
      debugPrint(
        "⚠️ INJECTION: No hay token guardado. El usuario iniciará como Guest o deberá hacer Login.",
      );
    }
  } catch (e) {
    debugPrint(
      "❌ INJECTION ERROR: Falló la recuperación del token al inicio: $e",
    );
  }
}
