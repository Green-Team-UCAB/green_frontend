import 'package:flutter/material.dart';
import 'package:green_frontend/features/single_player/presentation/provider/single_game_provider.dart'; 
import 'package:provider/provider.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<QuizProvider>(context, listen: false).startAttempt('tu-kahoot-id');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<QuizProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return Center(child: CircularProgressIndicator());
          if (provider.errorMessage != null) return Center(child: Text('Error: ${provider.errorMessage}'));
          if (provider.isQuizCompleted && provider.summary != null) {
            // Pantalla de resumen
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Puntuación Final: ${provider.summary!.finalScore}'),
                  Text('Respuestas Correctas: ${provider.summary!.totalCorrectAnswers}/${provider.summary!.totalQuestions}'),
                  Text('Precisión: ${provider.summary!.accuracyPercentage}%'),
                ],
              ),
            );
          }
          if (provider.currentSlide == null) return Center(child: Text('Esperando slide...'));

          final slide = provider.currentSlide!;
          return Container(
            width: double.infinity,
            height: double.infinity,
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                colors: [Colors.blue, Colors.green, Colors.purple],  
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Temporizador
                Text(
                  "Tiempo: ${provider.remainingTime}s",
                  style: TextStyle(fontSize: 20, color: provider.remainingTime > 10 ? Colors.white : Colors.red),
                ),
                SizedBox(height: 20),

                // Media (imagen/video si existe)
                if (slide.mediaId != null)
                  Image.network('https://backcomun-production.up.railway.app/${slide.mediaId}', height: 150)  
                else
                  Container(height: 150, color: Colors.grey, child: Center(child: Text("Sin media"))),
                SizedBox(height: 20),

                // Pregunta
                Text(
                  slide.questionText,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),

                // Opciones 
                ...slide.options.map((option) {
                  final isSelected = provider.selectedOptions.contains(option.index);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ElevatedButton(
                      onPressed: provider.remainingTime > 0 ? () => provider.selectOption(option.index) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected ? Colors.orange : Colors.blue,
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text(option.text ?? 'Opción ${option.index}', style: TextStyle(fontSize: 18)),
                    ),
                  );
                }),

                // Botón enviar 
                if (provider.selectedOptions.isNotEmpty)
                  ElevatedButton(
                    onPressed: () => provider.submitAnswer(),
                    child: Text("Enviar Respuesta"),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}