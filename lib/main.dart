import 'package:flutter/material.dart';
import 'package:green_frontend/core/theme/app_pallete.dart';
import 'package:green_frontend/features/kahoot/application/providers/kahoot_provider.dart';
import 'package:green_frontend/features/kahoot/application/providers/theme_provider.dart';
import 'package:green_frontend/features/kahoot/application/use_cases/save_kahoot_use_case.dart';
import 'package:green_frontend/features/kahoot/infrastructure/datasources/kahoot_remote_datasource.dart';
import 'package:green_frontend/features/kahoot/infrastructure/datasources/theme_remote_datasource.dart';
import 'package:green_frontend/features/kahoot/infrastructure/repositories/kahoot_repository_impl.dart';
import 'package:green_frontend/features/kahoot/infrastructure/repositories/theme_repository_impl.dart';
import 'package:green_frontend/features/menu_navegation/presentation/screens/nav_bar_selection_screen.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'features/menu_navegation/presentation/providers/navigation_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // DataSource para Kahoot
        Provider<KahootRemoteDataSource>(
          create: (_) => KahootRemoteDataSource(),
        ),
        // Repositorio para Kahoot
        Provider<KahootRepositoryImpl>(
          create: (context) => KahootRepositoryImpl(
            context.read<KahootRemoteDataSource>(),
          ),
        ),
        // Provider para Kahoot con UseCase
        ChangeNotifierProvider(
          create: (context) => KahootProvider(
            SaveKahootUseCase(
              context.read<KahootRepositoryImpl>(),
            ),
          ),
        ),
        // DataSource para Temas 
        Provider<ThemeRemoteDataSource>(
          create: (_) => ThemeRemoteDataSource(client: http.Client()),
          // La Url ya está configurada internamente como 'http://10.0.2.2:3000'
        ),
        // Repositorio para Temas
        Provider<ThemeRepositoryImpl>(
          create: (context) => ThemeRepositoryImpl(
            remoteDataSource: context.read<ThemeRemoteDataSource>(),
          ),
        ),
        // Provider para Temas
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) => ThemeProvider(
            themeRepository: context.read<ThemeRepositoryImpl>(),
          ),
        ),
        // Provider para Navegación (del segundo main)
        ChangeNotifierProvider(create: (_) => NavigationProvider()),  
      ],
      child: MaterialApp(
        title: 'Quiz App', // Usé el título del segundo main, puedes cambiarlo
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.purple, // Del primer main
          visualDensity: VisualDensity.adaptivePlatformDensity, // Del primer main
          scaffoldBackgroundColor: AppPallete.backgroundColor, // Del segundo main
        ),
        home: const NavBarSelectionScreen(), // Pantalla inicial del segundo main
        // Si quieres usar CreateKahootScreen como pantalla inicial, cámbialo por:
        // home: CreateKahootScreen(),
      ),
    );
  }
}