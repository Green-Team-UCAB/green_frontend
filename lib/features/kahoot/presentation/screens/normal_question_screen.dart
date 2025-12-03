import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kahoot_project/features/kahoot/application/providers/kahoot_provider.dart';
import 'package:kahoot_project/features/kahoot/domain/entities/question.dart';
import 'package:kahoot_project/features/kahoot/domain/entities/answer.dart';
import 'media_selection_screen.dart';

class NormalQuestionScreen extends StatefulWidget {
  final int? questionIndex;

  const NormalQuestionScreen({Key? key, this.questionIndex}) : super(key: key);

  @override
  _NormalQuestionScreenState createState() => _NormalQuestionScreenState();
}

class _NormalQuestionScreenState extends State<NormalQuestionScreen> {
  final _questionTextController = TextEditingController();
  int _timeLimit = 20;
  List<Answer> _answers = [
    Answer(text: '', isCorrect: false),
    Answer(text: '', isCorrect: false),
    Answer(text: '', isCorrect: false),
    Answer(text: '', isCorrect: false),
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
    _answers = question.answers;
    _selectedMediaId = question.mediaId;
  }

  void _addAnswer() {
    setState(() {
      _answers.add(Answer(text: '', isCorrect: false));
    });
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
      text: _questionTextController.text,
      mediaId: _selectedMediaId,
      timeLimitSeconds: _timeLimit,
      type: QuestionType.quiz,
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
        title: Text('Quiz - Pregunta'),
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
                Icon(Icons.quiz, color: Colors.purple),
                SizedBox(width: 8),
                Text('Quiz', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

            // Respuestas
            Text('Respuestas:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            ..._answers.asMap().entries.map((entry) {
              final index = entry.key;
              final answer = entry.value;
              return Card(
                margin: EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Respuesta ${index + 1}',
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _answers[index].text = value;
                            });
                          },
                        ),
                      ),
                      Checkbox(
                        value: answer.isCorrect,
                        onChanged: (value) {
                          setState(() {
                            _answers[index].isCorrect = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),

            // Botón para añadir más respuestas
            TextButton.icon(
              icon: Icon(Icons.add),
              label: Text('Añadir respuesta'),
              onPressed: _addAnswer,
            ),
          ],
        ),
      ),
    );
  }
}