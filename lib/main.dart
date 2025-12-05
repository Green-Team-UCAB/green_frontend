import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:green_frontend/features/single_player/infraestructure/repositories/async_game_repository_impl.dart';
import 'package:green_frontend/features/single_player/application/start_attempt.dart';  
import 'package:green_frontend/features/single_player/application/get_attempt.dart';
import 'package:green_frontend/features/single_player/application/submit_answer.dart';  
import 'package:green_frontend/features/single_player/application/get_summary.dart';
import 'package:green_frontend/features/single_player/application/get_kahoot_preview.dart';
import 'package:green_frontend/features/single_player/infraestructure/datasources/async_game_datasource.dart';
import 'package:dio/dio.dart';
import 'package:green_frontend/core/mappers/exception_failure_mapper.dart';
import 'package:green_frontend/features/single_player/presentation/screens/kahoot_preview_page.dart';
import 'package:green_frontend/features/single_player/presentation/provider/game_provider.dart';


void main() {
  
  const baseUrl = 'https://quizzy-backend-0wh2.onrender.com/api'; 
  final dio = Dio(BaseOptions(baseUrl: baseUrl, connectTimeout: const Duration(seconds: 30), receiveTimeout: const Duration(seconds: 30)));
  final dataSource = AsyncGameDataSourceImpl(dio: dio);
  final mapper = ExceptionFailureMapper();
  final repository = AsyncGameRepositoryImpl(dataSource: dataSource, mapper: mapper);

  final startUC = StartAttempt(repository);
  final getAttemptUC = GetAttempt(repository);
  final submitUC = SubmitAnswer(repository);
  final summaryUC = GetSummary(repository);
  final previewUC = GetKahootPreview(repository);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => GameController(
            startAttempt: startUC,
            getAttempt: getAttemptUC,
            submitAnswer: submitUC,
            getSummary: summaryUC,
            getKahootPreview: previewUC,
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
    return MaterialApp(
      title: 'Kahoot Demo',
      theme: ThemeData(useMaterial3: true),
      home: const KahootPreviewScreen(kahootId: '1c7ebd51-ab08-4f29-b0b3-14ad7429f83f'),
    );
  }
}
