import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Importamos el contenedor de inyección de dependencias
// (Asumimos que crearás este archivo en el siguiente paso, ver abajo)
import 'injection_container.dart' as di;

// Importamos la página principal de la Feature H6.1 (Discovery)
import 'features/discovery/presentation/pages/discovery_page.dart';

void main() async {
  // 1. Aseguramos que el motor de Flutter esté inicializado antes que nada.
  // Esto es necesario para usar plugins, bases de datos locales o SharedPreferences.
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicializamos la Inyección de Dependencias (GetIt).
  // Aquí se registran todos los Blocs, Repositorios y DataSources.
  await di.init();

  // 3. Configuramos un Observer global para BLoC.
  // Esto nos permite ver en la consola todos los cambios de estado y eventos
  // (Muy útil para debugging).
  Bloc.observer = AppBlocObserver();

  // 4. Ejecutamos la aplicación
  runApp(const MyApp());
}

/// Widget raíz de la aplicación.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Título de la tarea en el administrador de aplicaciones del SO
      title: 'Kahoot Clone',

      // Desactivamos la etiqueta "DEBUG" en la esquina
      debugShowCheckedModeBanner: false,

      // Configuración del Tema (Material 3)
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple, // Color primario base
          brightness: Brightness.light,
        ),
        useMaterial3: true, // Habilitamos Material 3
        // Estilos globales para Inputs (opcional pero recomendado)
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
        ),
      ),

      // RUTAS / PÁGINA DE INICIO
      // Para la Épica H6.1, definimos DiscoveryPage como la home temporalmente.
      home: const DiscoveryPage(),
    );
  }
}

/// Clase auxiliar para observar el ciclo de vida de los BLoCs en consola.
class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    // Imprime: DiscoveryBloc, Change { currentState: ..., nextState: ... }
    debugPrint('${bloc.runtimeType} $change');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    debugPrint('${bloc.runtimeType} $error');
    super.onError(bloc, error, stackTrace);
  }
}
