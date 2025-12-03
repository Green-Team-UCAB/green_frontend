import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kahoot_project/features/kahoot/application/providers/kahoot_provider.dart';
import 'package:kahoot_project/features/kahoot/domain/entities/question.dart';
import 'package:kahoot_project/features/kahoot/domain/entities/answer.dart';
import 'media_selection_screen.dart';

class TrueFalseQuestionScreen extends StatefulWidget {
  final int? questionIndex;

  const TrueFalseQuestionScreen({Key? key, this.questionIndex}) : super(key: key);

  @override
  _TrueFalseQuestionScreenState createState() => _TrueFalseQuestionScreenState();
}

class _TrueFalseQuestionScreenState extends State<TrueFalseQuestionScreen> {
  final _questionTextController = TextEditingController();
  int _timeLimit = 20;
  List<Answer> _answers = [
    Answer(text: 'Verdadero', isCorrect: false),
    Answer(text: 'Falso', isCorrect: false),
  ];
  String? _selectedMediaId;

  @override
  void initState() {
    super.initState();
    if (widget.questionIndex != null) {
      _loadQuestion();
    }
  }

  void _loadQuestion() {
    final kahootProvider = Provider.of<KahootProvider>(context, listen: false);
    final question = kahootProvider.currentKahoot.questions[widget.questionIndex!];
    
    _questionTextController.text = question.text;
    _timeLimit = question.timeLimitSeconds;
    _answers = question.answers.map((a) => Answer(
      id: a.id,
      text: a.text,
      mediaId: a.mediaId,
      isCorrect: a.isCorrect,
    )).toList();
    _selectedMediaId = question.mediaId;
  }

  void _saveQuestion() {
    if (_questionTextController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, ingresa la pregunta')),
      );
      return;
    }

    final kahootProvider = Provider.of<KahootProvider>(context, listen: false);
    final question = Question(
      id: widget.questionIndex != null 
          ? kahootProvider.currentKahoot.questions[widget.questionIndex!].id 
          : null,
      text: _questionTextController.text,
      mediaId: _selectedMediaId,
      timeLimitSeconds: _timeLimit,
      type: QuestionType.trueFalse,
      answers: _answers,
    );

    if (widget.questionIndex == null) {
      kahootProvider.addQuestion(question);
    } else {
      kahootProvider.updateQuestion(widget.questionIndex!, question);
    }
    
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verdadero o Falso'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _saveQuestion,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título del tipo de pregunta
            Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.green),
                SizedBox(width: 8),
                Text('Verdadero o Falso', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 20),
            // Campo de pregunta
            TextField(
              controller: _questionTextController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Pregunta',
                hintText: 'Pulsa para añadir una pregunta',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            // Botón para añadir multimedia
            ElevatedButton.icon(
              icon: Icon(Icons.image),
              label: Text('Añadir multimedia'),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MediaSelectionScreen()),
                );
                if (result != null) {
                  setState(() {
                    _selectedMediaId = result;
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            SizedBox(height: 20),
            // Temporizador
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tiempo límite: $_timeLimit s'),
                Switch(
                  value: true,
                  onChanged: (value) {},
                ),
              ],
            ),
            Slider(
              value: _timeLimit.toDouble(),
              min: 5,
              max: 120,
              divisions: 23,
              label: '$_timeLimit s',
              onChanged: (value) {
                setState(() {
                  _timeLimit = value.round();
                });
              },
            ),
            SizedBox(height: 20),
            // Opciones Verdadero/Falso
            Text('Opciones:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Card(
              child: ListTile(
                title: Text('Verdadero', style: TextStyle(fontWeight: FontWeight.bold)),
                trailing: Checkbox(
                  value: _answers[0].isCorrect,
                  onChanged: (value) {
                    setState(() {
                      _answers[0].isCorrect = value!;
                      _answers[1].isCorrect = !value;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 8),
            Card(
              child: ListTile(
                title: Text('Falso', style: TextStyle(fontWeight: FontWeight.bold)),
                trailing: Checkbox(
                  value: _answers[1].isCorrect,
                  onChanged: (value) {
                    setState(() {
                      _answers[1].isCorrect = value!;
                      _answers[0].isCorrect = !value;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}