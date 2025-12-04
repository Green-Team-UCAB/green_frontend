import 'package:flutter/material.dart';
import 'package:kahoot_project/features/kahoot/infrastructure/datasources/theme_remote_datasource.dart';
import 'package:kahoot_project/features/kahoot/infrastructure/repositories/theme_repository_impl.dart';
import 'package:provider/provider.dart';
import 'package:kahoot_project/features/kahoot/application/providers/kahoot_provider.dart';
import 'package:kahoot_project/features/kahoot/application/providers/theme_provider.dart';
import 'package:kahoot_project/features/kahoot/presentation/screens/create_kahoot_screen.dart';
import 'package:kahoot_project/features/kahoot/infrastructure/datasources/kahoot_remote_datasource.dart';
import 'package:kahoot_project/features/kahoot/infrastructure/repositories/kahoot_repository_impl.dart';
import 'package:kahoot_project/features/kahoot/application/use_cases/save_kahoot_use_case.dart';
import 'package:http/http.dart' as http;



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
      ],
      child: MaterialApp(
        title: 'Kahoot Creator',
        theme: ThemeData(
          primarySwatch: Colors.purple,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: CreateKahootScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}