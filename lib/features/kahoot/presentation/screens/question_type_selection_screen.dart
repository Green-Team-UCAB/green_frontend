import 'package:flutter/material.dart';
import 'normal_question_screen.dart';
import 'true_false_question_screen.dart';

class QuestionTypeSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tipo de pregunta'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NormalQuestionScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Column(
                children: [
                  Icon(Icons.quiz, size: 40),
                  SizedBox(height: 10),
                  Text('Quiz', style: TextStyle(fontSize: 18)),
                  Text('Selección múltiple', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TrueFalseQuestionScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Column(
                children: [
                  Icon(Icons.check_circle_outline, size: 40),
                  SizedBox(height: 10),
                  Text('Verdadero o falso', style: TextStyle(fontSize: 18)),
                  Text('Solo dos opciones', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}