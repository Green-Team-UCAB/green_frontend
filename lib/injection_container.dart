import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:green_frontend/features/groups/presentation/bloc/detail/group_detail_bloc.dart';
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
import 'features/library/data/datasources/library_remote_data_source.dart';
import 'features/library/data/repositories/library_repository_impl.dart';
import 'features/library/domain/repositories/library_repository.dart';
import 'features/library/presentation/bloc/library_bloc.dart';

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
  // Usamos registerFactory para que se cree una nueva instancia
  // cada vez que la UI lo solicite (por ejemplo, al cerrar y abrir la pantalla).
  sl.registerFactory(() => DiscoveryBloc(repository: sl()));

  // 2. Repository
  // Usamos registerLazySingleton para mantener una única instancia en memoria.
  sl.registerLazySingleton<DiscoveryRepository>(
    () => DiscoveryRepositoryImpl(remoteDataSource: sl()),
  );

  // 3. Data Source
  // Usamos registerLazySingleton. Aquí es donde pondríamos el cliente HTTP (Dio)
  // en el futuro.
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
  sl.registerLazySingleton<ReportsRemoteDataSource>(
    () => ReportsRemoteDataSourceImpl(),
  );

  //! Features - Library (Epica 7)
  sl.registerFactory(() => LibraryBloc(repository: sl()));
  sl.registerLazySingleton<LibraryRepository>(
    () => LibraryRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<LibraryRemoteDataSource>(
    () => LibraryRemoteDataSourceImpl(),
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

  //! Core & External
  sl.registerLazySingleton(
    () => Dio(
      BaseOptions(
        baseUrl: 'https://quizzy-backend-0wh2.onrender.com/api',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    ),
  );
  sl.registerLazySingleton(() => ApiClient(sl()));
}
