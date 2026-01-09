import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:green_frontend/features/auth/presentation/screens/splash_page.dart';
import 'package:green_frontend/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:green_frontend/features/auth/application/register_user.dart';
import 'package:green_frontend/features/auth/application/login_user.dart';
import 'package:green_frontend/features/auth/infraestructure/repositories/auth_repository_impl.dart';
import 'package:green_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:green_frontend/features/auth/infraestructure/datasources/auth_datasource.dart';
import 'package:green_frontend/core/mappers/exception_failure_mapper.dart';

import 'injection_container.dart' as di;
import 'package:green_frontend/core/theme/app_pallete.dart';

// --- Feature: Navigation ---
import 'features/menu_navegation/presentation/providers/navigation_provider.dart';

// --- Feature: Kahoot ---
import 'package:green_frontend/features/kahoot/application/providers/kahoot_provider.dart';
import 'package:green_frontend/features/kahoot/application/use_cases/save_kahoot_use_case.dart';
import 'package:green_frontend/features/kahoot/infrastructure/datasources/kahoot_remote_datasource.dart';
import 'package:green_frontend/features/kahoot/infrastructure/repositories/kahoot_repository_impl.dart';

// --- Feature: Theming ---
import 'package:green_frontend/features/kahoot/application/providers/theme_provider.dart';
import 'package:green_frontend/features/kahoot/infrastructure/datasources/theme_remote_datasource.dart';
import 'package:green_frontend/features/kahoot/infrastructure/repositories/theme_repository_impl.dart';

// --- Feature: Single Player ---
import 'package:green_frontend/features/single_player/application/start_attempt.dart';
import 'package:green_frontend/features/single_player/application/get_attempt.dart';
import 'package:green_frontend/features/single_player/application/submit_answer.dart';
import 'package:green_frontend/features/single_player/application/get_summary.dart';
import 'package:green_frontend/features/single_player/application/get_kahoot_preview.dart';
import 'package:green_frontend/features/single_player/infraestructure/repositories/async_game_repository_impl.dart';
import 'package:green_frontend/features/single_player/infraestructure/datasources/async_game_datasource.dart';

import 'package:green_frontend/features/single_player/presentation/provider/game_provider.dart';

import 'package:green_frontend/core/network/api_client.dart';

void main() async {
  // Configuración de inicialización
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ CORRECCIÓN CRÍTICA: Inicializar datos de fecha para español
  // Esto evita el error: "Locale data has not been initialized"
  await initializeDateFormatting('es');

  await di.init();
  Bloc.observer = AppBlocObserver();

  // --- Inicialización y registro temporal de dependencias Single Player ---
  const baseUrl = 'https://quizzy-backend-0wh2.onrender.com/api';
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );
  final dataSource = AsyncGameDataSourceImpl(dio: dio);
  final mapper = ExceptionFailureMapper();
  final repository = AsyncGameRepositoryImpl(
    dataSource: dataSource,
    mapper: mapper,
  );

  // Inicialización de Use Cases (Single Player)
  final startUC = StartAttempt(repository);
  final getAttemptUC = GetAttempt(repository);
  final submitUC = SubmitAnswer(repository);
  final summaryUC = GetSummary(repository);
  final previewUC = GetKahootPreview(repository);
  // -------------------------------------------------------------------

  runApp(
    MultiProvider(
      providers: [
        // Datasource de Autenticación
        Provider<AuthDataSource>(
          create: (_) => AuthRemoteDataSourceImpl(client: di.sl<ApiClient>()),
        ),
        // Proveedores de Use Cases de Single Player
        Provider<StartAttempt>(create: (_) => startUC),
        Provider<GetAttempt>(create: (_) => getAttemptUC),
        Provider<SubmitAnswer>(create: (_) => submitUC),
        Provider<GetSummary>(create: (_) => summaryUC),
        Provider<GetKahootPreview>(create: (_) => previewUC),
        // Mapper de excepciones
        Provider<ExceptionFailureMapper>(
          create: (_) => ExceptionFailureMapper(),
        ),

        // Implementacion de repositorio de Autenticación
        Provider<AuthRepository>(
          create: (ctx) => AuthRepositoryImpl(
            dataSource: ctx.read<AuthDataSource>(),
            mapper: ctx.read<ExceptionFailureMapper>(),
          ),
        ),

        // Casos de uso de Autenticación
        Provider<RegisterUserUseCase>(
          create: (ctx) => RegisterUserUseCase(ctx.read<AuthRepository>()),
        ),
        Provider<LoginUserUseCase>(
          create: (ctx) => LoginUserUseCase(ctx.read<AuthRepository>()),
        ),
        // Bloc de autenticación
        BlocProvider<AuthBloc>(
          create: (ctx) => AuthBloc(
            registerUser: ctx.read<RegisterUserUseCase>(),
            loginUser: ctx.read<LoginUserUseCase>(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),

        Provider<KahootRemoteDataSource>(
          create: (_) => KahootRemoteDataSource(),
        ),
        Provider<KahootRepositoryImpl>(
          create: (context) =>
              KahootRepositoryImpl(context.read<KahootRemoteDataSource>()),
        ),
        ChangeNotifierProvider(
          create: (context) => KahootProvider(
            SaveKahootUseCase(context.read<KahootRepositoryImpl>()),
          ),
        ),
        Provider<ThemeRemoteDataSource>(
          create: (_) => ThemeRemoteDataSource(client: http.Client()),
        ),
        Provider<ThemeRepositoryImpl>(
          create: (context) => ThemeRepositoryImpl(
            remoteDataSource: context.read<ThemeRemoteDataSource>(),
          ),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) => ThemeProvider(
            themeRepository: context.read<ThemeRepositoryImpl>(),
          ),
        ),

        ChangeNotifierProvider(
          create: (context) => GameController(
            // Usa los Use Cases registrados en el MultiProvider de main()
            startAttempt: context.read<StartAttempt>(),
            getAttempt: context.read<GetAttempt>(),
            submitAnswer: context.read<SubmitAnswer>(),
            getSummary: context.read<GetSummary>(),
            getKahootPreview: context.read<GetKahootPreview>(),
          ),
        ),
      ],

      child: MaterialApp(
        title: 'Kahoot Clone',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // Combinación de configuraciones de tema
          scaffoldBackgroundColor: AppPallete.backgroundColor,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        // Asegúrate de que el locale esté soportado si usas intl para UI
        // supportedLocales: const [Locale('es', '')],
        home: const SplashPage(),
      ),
    );
  }
}

// -------------------------------------------------------------------

/// Observador global para monitorear cambios de estado en BLoC
class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    debugPrint('${bloc.runtimeType} $change');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    debugPrint('${bloc.runtimeType} $error');
    super.onError(bloc, error, stackTrace);
  }
}
