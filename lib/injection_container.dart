import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:green_frontend/features/groups/presentation/bloc/detail/group_detail_bloc.dart';
import 'package:green_frontend/core/storage/token_storage.dart';
import 'package:flutter/foundation.dart'; // Para debugPrint
import 'core/network/api_client.dart';

// Imports de la Feature Discovery (H6.1)
import 'features/discovery/data/datasources/discovery_remote_data_source.dart';
import 'features/discovery/data/repositories/discovery_repository_impl.dart';
import 'features/discovery/domain/repositories/discovery_repository.dart';
import 'features/discovery/presentation/bloc/discovery_bloc.dart';

// Imports de la Feature Reports (H6.2)
import 'features/reports/data/datasources/reports_remote_data_source.dart';
import 'features/reports/data/repositories/reports_repository_impl.dart';
import 'features/reports/domain/repositories/reports_repository.dart';
import 'features/reports/presentation/bloc/reports_bloc.dart';
import 'features/reports/presentation/bloc/report_detail_bloc.dart';
import 'features/reports/presentation/bloc/host_report_bloc.dart';

// Imports de Library
import 'features/library/infrastructure/datasources/library_remote_datasource.dart';
import 'features/library/infrastructure/datasources/library_repository_impl.dart';
import 'features/library/domain/repositories/library_repository.dart';
import 'features/library/presentation/bloc/library_bloc.dart';
// Use Cases
import 'features/library/application/get_my_kahoots_use_case.dart';
import 'features/library/application/get_favorites_use_case.dart';
import 'features/library/application/get_in_progress_use_case.dart';
import 'features/library/application/get_completed_use_case.dart';
import 'features/library/application/toggle_favorite_use_case.dart';

// Imports de Groups
import 'features/groups/data/datasources/groups_remote_data_source.dart';
import 'features/groups/data/repositories/groups_repository_impl.dart';
import 'features/groups/domain/repositories/groups_repository.dart';
import 'features/groups/presentation/bloc/groups_bloc.dart';
import 'features/groups/presentation/bloc/settings/group_settings_bloc.dart';
import 'features/groups/presentation/bloc/selection/kahoot_selection_bloc.dart';

// Instancia global del Service Locator
final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Discovery (H6.1)

  // 1. Bloc
  sl.registerFactory(() => DiscoveryBloc(repository: sl()));

  // 2. Repository
  sl.registerLazySingleton<DiscoveryRepository>(
    () => DiscoveryRepositoryImpl(remoteDataSource: sl()),
  );

  // 3. Data Source
  // Nota: Si Discovery aún usa datos falsos sin HTTP, déjalo así.
  // Si ya lo actualizaste para usar http, agrégale (client: sl()).
  sl.registerLazySingleton<DiscoveryRemoteDataSource>(
    () => DiscoveryRemoteDataSourceImpl(apiClient: sl()),
  );

  //! Features - Reports (Epica 10)

  // Bloc
  sl.registerFactory(() => ReportsBloc(repository: sl()));
  sl.registerFactory(() => ReportDetailBloc(repository: sl()));
  sl.registerFactory(() => HostReportBloc(repository: sl()));

  // Repository
  sl.registerLazySingleton<ReportsRepository>(
    () => ReportsRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Source
  // ✅ CORREGIDO: Inyectamos el cliente HTTP
  sl.registerLazySingleton<ReportsRemoteDataSource>(
    () => ReportsRemoteDataSourceImpl(client: sl()),
  );

  //! Features - Library (Epica 7)

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
  // ✅ Inyectamos ApiClient
  sl.registerLazySingleton<LibraryRemoteDataSource>(
    () => LibraryRemoteDataSourceImpl(apiClient: sl()),
  );

  //! Features - Groups (Epica 8)
  sl.registerFactory(() => GroupsBloc(repository: sl()));

  // Repository
  sl.registerLazySingleton<GroupsRepository>(
    () => GroupsRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Source (Con ApiClient)
  sl.registerLazySingleton<GroupsRemoteDataSource>(
    () => GroupsRemoteDataSourceImpl(apiClient: sl()),
  );

  sl.registerFactory(() => GroupDetailBloc(repository: sl()));
  // Feature Groups - Settings Bloc
  sl.registerFactory(() => GroupSettingsBloc(repository: sl()));
  // Feature Groups - Selection Bloc
  sl.registerFactory(() => KahootSelectionBloc(repository: sl()));

  // Core & External
  sl.registerLazySingleton(
    () => Dio(
      BaseOptions(
        baseUrl: 'https://quizzy-backend-0wh2.onrender.com/api',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    ),
  );
  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl()));
  sl.registerLazySingleton<http.Client>(() => http.Client());

  // Recuperamos el token si existe y lo seteamos en el ApiClient
  final token = await TokenStorage.getToken();
  if (token != null) {
    sl<ApiClient>().setAuthToken(token);
    debugPrint("Token cargado al iniciar la app: $token"); // Log para verificar
  }
}
