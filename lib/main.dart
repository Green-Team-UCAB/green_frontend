import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kahoot_project/features/kahoot/application/providers/kahoot_provider.dart';
import 'package:kahoot_project/features/kahoot/application/providers/theme_provider.dart';
import 'package:kahoot_project/features/kahoot/presentation/screens/create_kahoot_screen.dart';
import 'package:kahoot_project/features/kahoot/infrastructure/datasources/kahoot_remote_datasource.dart';
import 'package:kahoot_project/features/kahoot/infrastructure/repositories/kahoot_repository_impl.dart';
import 'package:kahoot_project/features/kahoot/application/use_cases/save_kahoot_use_case.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<KahootRemoteDataSource>(
          create: (_) => KahootRemoteDataSource(),
        ),
        Provider<KahootRepositoryImpl>(
          create: (context) => KahootRepositoryImpl(
            context.read<KahootRemoteDataSource>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => KahootProvider(
            SaveKahootUseCase(
              context.read<KahootRepositoryImpl>(),
            ),
          ),
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
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