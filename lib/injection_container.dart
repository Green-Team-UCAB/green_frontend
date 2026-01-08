import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http; // <--- 1. IMPORTANTE: Importar http
import 'core/network/api_client.dart'; // Importar ApiClient

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
import 'features/library/data/datasources/library_remote_data_source.dart';
import 'features/library/data/repositories/library_repository_impl.dart';
import 'features/library/domain/repositories/library_repository.dart';
import 'features/library/presentation/bloc/library_bloc.dart';

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
    () => DiscoveryRemoteDataSourceImpl(),
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

  // Bloc
  sl.registerFactory(() => LibraryBloc(repository: sl()));

  // Repository
  sl.registerLazySingleton<LibraryRepository>(
    () => LibraryRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Source
  // ✅ Inyectamos ApiClient
  sl.registerLazySingleton<LibraryRemoteDataSource>(
    () => LibraryRemoteDataSourceImpl(apiClient: sl()),
  );

  //! Core & External

  // Registramos ApiClient
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient.withBaseUrl('https://quizzy-backend-0wh2.onrender.com/api'),
  );

  // Registramos el cliente HTTP (usado por Reports)
  sl.registerLazySingleton(() => http.Client());
}
