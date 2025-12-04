import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Importamos el contenedor de inyección de dependencias
import 'injection_container.dart' as di;

// Importamos la página de Reportes (Épica 10)
import 'features/reports/presentation/pages/reports_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializamos dependencias
  await di.init();

  Bloc.observer = AppBlocObserver();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kahoot Clone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
        ),
        // NOTA: Eliminamos 'cardTheme' para evitar el error de tipos.
        // Los estilos de las tarjetas se manejarán en cada widget individualmente.
      ),
      // Arrancamos directo en la pantalla de Informes
      home: const ReportsPage(),
    );
  }
}

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
