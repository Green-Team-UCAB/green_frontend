import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

// --- Core & Dependency Injection ---
import 'injection_container.dart' as di;
import 'package:green_frontend/core/theme/app_pallete.dart';

// --- Feature: Navigation ---
import 'features/menu_navegation/presentation/screens/nav_bar_selection_screen.dart';
import 'features/menu_navegation/presentation/providers/navigation_provider.dart';

// --- Feature: Kahoot (Creation & Logic) ---
import 'package:green_frontend/features/kahoot/application/providers/kahoot_provider.dart';
import 'package:green_frontend/features/kahoot/application/use_cases/save_kahoot_use_case.dart';
import 'package:green_frontend/features/kahoot/infrastructure/datasources/kahoot_remote_datasource.dart';
import 'package:green_frontend/features/kahoot/infrastructure/repositories/kahoot_repository_impl.dart';

// --- Feature: Theming ---
import 'package:green_frontend/features/kahoot/application/providers/theme_provider.dart';
import 'package:green_frontend/features/kahoot/infrastructure/datasources/theme_remote_datasource.dart';
import 'package:green_frontend/features/kahoot/infrastructure/repositories/theme_repository_impl.dart';

void main() async {
  // Asegurar inicialización del motor de Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Service Locator (Clean Architecture Dependencies)
  await di.init();

  // Configuración de observador para BLoC
  Bloc.observer = AppBlocObserver();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ---------------------------------------------------
        // Feature: Navigation
        // ---------------------------------------------------
        ChangeNotifierProvider(create: (_) => NavigationProvider()),

        // ---------------------------------------------------
        // Feature: Kahoot (Management & Creation)
        // ---------------------------------------------------
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

        // ---------------------------------------------------
        // Feature: Themes
        // ---------------------------------------------------
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
      ],

      child: MaterialApp(
        title: 'Kahoot Clone',
        debugShowCheckedModeBanner: false,

        // Configuración Global de Tema
        theme: ThemeData(
          // Paleta de colores principal
          scaffoldBackgroundColor: AppPallete.backgroundColor,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          ),
          useMaterial3: true,

          // Estilos de Inputs
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
          ),
        ),

        // Pantalla Inicial (Barra de Navegación)
        home: const NavBarSelectionScreen(),
      ),
    );
  }
}

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
