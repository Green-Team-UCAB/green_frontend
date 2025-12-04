import 'package:flutter/material.dart';
import '../widgets/option_field.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final List<String> options = ["Opción A", "Opción B", "Opción C", "Opción D"];
  void handleAnswer(String answer) {
    print("Seleccionaste: $answer");
    // Provider/
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quiz Page")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              '¿Cuál es la respuesta correcta?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            OptionField(
              options: options,
              onSelected: handleAnswer,
            ),
          ],
        ),
      ),
    );
  }
}