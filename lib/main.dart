import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:green_frontend/features/single_player/infraestructure/repositories/async_game_repository_impl.dart';
import 'package:green_frontend/features/single_player/application/start_attempt.dart';  
import 'package:green_frontend/features/single_player/application/get_attempt.dart';
import 'package:green_frontend/features/single_player/application/submit_answer.dart';  
import 'package:green_frontend/features/single_player/application/get_summary.dart';
import 'package:green_frontend/features/single_player/presentation/provider/single_game_provider.dart'; 
import 'package:green_frontend/features/single_player/presentation/screens/example.dart';
import 'package:green_frontend/features/single_player/infraestructure/datasources/async_game_datasource.dart';
import 'package:dio/dio.dart';

void main() {
  final dio = Dio(BaseOptions(
  baseUrl: 'https://backcomun-production.up.railway.app', 
  connectTimeout: const Duration(seconds: 8),
  receiveTimeout: const Duration(seconds: 8),
  headers: {'Content-Type': 'application/json'},
)); 
  final dataSource = AsyncGameDatasourceImpl(dio: dio);
  final repo = AsyncGameRepositoryImpl(dataSource: dataSource);
  runApp(MyApp(repo: repo));
}

class MyApp extends StatelessWidget {
  final AsyncGameRepositoryImpl repo;
  const MyApp({super.key, required this.repo});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Proporciona QuizProvider con instancias creadas manualmente
        ChangeNotifierProvider<QuizProvider>(
          create: (_) => QuizProvider(
            startAttemptUseCase: StartAttempt(repo),
            getAttemptUseCase: GetAttempt(repo),
            submitAnswerUseCase: SubmitAnswer(repo),
            getSummaryUseCase: GetSummary(repo),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Trivia App',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: QuizScreen(),  // Pantalla inicial
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
