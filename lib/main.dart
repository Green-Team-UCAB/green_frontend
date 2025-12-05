import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

// 1. TUS IMPORTS (Inyección de dependencias)
import 'injection_container.dart' as di;

// 2. IMPORTS DEL EQUIPO (Navegación)
// Asegúrate que estas rutas existan. Si te salen rojas, verifica la carpeta.
import 'features/menu_navegation/presentation/screens/nav_bar_selection_screen.dart';
import 'features/menu_navegation/presentation/providers/navigation_provider.dart';

// 3. IMPORT DE TEMA (Opcional)
// Si tienes este archivo, descoméntalo. Si no, usa colores por defecto.
// import 'core/theme/app_pallete.dart';

void main() async {
  // Aseguramos que el motor de Flutter esté listo
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ VITAL: Inicializamos TUS dependencias (GetIt)
  // Sin esto, tus pantallas de Discovery y Library fallarán al buscar los Blocs.
  await di.init();

  // Configuración de logs para Bloc
  Bloc.observer = AppBlocObserver();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ✅ PROVIDER DE NAVEGACIÓN (Del equipo)
        // Es necesario para que funcione el NavBarSelectionScreen
        ChangeNotifierProvider(create: (_) => NavigationProvider()),

        // NOTA: Aquí irían los providers de Kahoot/Theme del equipo.
        // Los he omitido para que te compile AHORA.
        // Cuando tengas esos archivos, agrégalos aquí.
      ],
      child: MaterialApp(
        title: 'Kahoot Clone',
        debugShowCheckedModeBanner: false,

        // Configuración del Tema
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          // Configuración global de inputs (opcional, para que se vea bien)
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
          ),
          // Si tienes AppPallete, puedes usar: scaffoldBackgroundColor: AppPallete.backgroundColor,
        ),

        // 🚀 PUNTO DE ENTRADA
        // Arrancamos con la pantalla de menú de tu equipo.
        // Dentro de esta pantalla, ellos deben estar llamando a tus páginas (LibraryPage, DiscoveryPage)
        home: const NavBarSelectionScreen(),
      ),
    );
  }
}

// Tu observador de Bloc para ver los logs en consola
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
