import 'package:get_it/get_it.dart';

// Imports de la Feature Discovery (H6.1)
import 'features/discovery/data/datasources/discovery_remote_data_source.dart';
import 'features/discovery/data/repositories/discovery_repository_impl.dart';
import 'features/discovery/domain/repositories/discovery_repository.dart';
import 'features/discovery/presentation/bloc/discovery_bloc.dart';

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
    () => DiscoveryRemoteDataSourceImpl(),
  );

  //! Core & External
  // Aquí registraríamos cosas como SharedPreferences, Dio, Connectivity, etc.
  // Por ahora lo dejamos vacío hasta que lo necesitemos.
}
