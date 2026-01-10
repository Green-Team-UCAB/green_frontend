import 'package:flutter/material.dart';
import 'package:green_frontend/features/kahoot/application/providers/kahoot_provider.dart';
import 'package:green_frontend/features/kahoot/domain/entities/answer.dart';
import 'package:green_frontend/features/kahoot/domain/entities/question.dart';
import 'package:provider/provider.dart';
import 'media_selection_screen.dart';

class NormalQuestionScreen extends StatefulWidget {
  final int? questionIndex;

  const NormalQuestionScreen({Key? key, this.questionIndex}) : super(key: key);

  @override
  _NormalQuestionScreenState createState() => _NormalQuestionScreenState();
}

class _NormalQuestionScreenState extends State<NormalQuestionScreen> {
  final _questionTextController = TextEditingController();
  int _timeLimit = 20; // CAMBIADO: variable renombrada
  final List<Answer> _answers = [];
  final List<TextEditingController> _answerControllers = [];
  String? _selectedMediaId;
  int _points = 1000;

  @override
  void initState() {
    super.initState();
    if (widget.questionIndex != null) {
      _loadQuestion();
    } else {
      for (int i = 0; i < 4; i++) {
        _answers.add(Answer(text: '', isCorrect: false));
        _answerControllers.add(TextEditingController());
      }
    }
  }

  void _loadQuestion() {
    final kahootProvider = Provider.of<KahootProvider>(context, listen: false);
    final question =
        kahootProvider.currentKahoot.questions[widget.questionIndex!];

    _questionTextController.text = question.text;
    _timeLimit = question
        .timeLimit; // CAMBIADO: usar timeLimit en lugar de timeLimitSeconds
    if (_timeLimit <= 0) _timeLimit = 20;
    _selectedMediaId = question.mediaId;
    _points = question.points;
    if (_points <= 0) _points = 1000;

    _answers.clear();
    _answerControllers.clear();

    for (var answer in question.answers) {
      _answers.add(
        Answer(
          id: answer.id,
          text: answer.text,
          mediaId: answer.mediaId,
          isCorrect: answer.isCorrect,
        ),
      );
      _answerControllers.add(TextEditingController(text: answer.text));
    }
  }

  void _addAnswer() {
    setState(() {
      _answers.add(Answer(text: '', isCorrect: false));
      _answerControllers.add(TextEditingController());
    });
  }

  void _saveQuestion() {
    // Validaciones
    if (_questionTextController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Por favor, ingresa la pregunta')));
      return;
    }

    if (_points <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('El puntaje debe ser un número positivo')),
      );
      return;
    }

    // Asegurar que timeLimit sea positivo
    if (_timeLimit <= 0) {
      _timeLimit = 20;
    }

    final hasCorrectAnswer = _answers.any((answer) => answer.isCorrect);
    if (!hasCorrectAnswer) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Debe marcar al menos una respuesta como correcta'),
        ),
      );
      return;
    }

    for (var i = 0; i < _answers.length; i++) {
      if (_answers[i].text == null || _answers[i].text!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('La respuesta ${i + 1} no puede estar vacía')),
        );
        return;
      }
    }

    final kahootProvider = Provider.of<KahootProvider>(context, listen: false);
    final question = Question(
      id: widget.questionIndex != null
          ? kahootProvider.currentKahoot.questions[widget.questionIndex!].id
          : null,
      text: _questionTextController.text,
      mediaId: _selectedMediaId,
      timeLimit: _timeLimit, // CAMBIADO
      type: QuestionType.quiz,
      answers: _answers,
      points: _points,
    );

    if (widget.questionIndex == null) {
      kahootProvider.addQuestion(question);
    } else {
      kahootProvider.updateQuestion(widget.questionIndex!, question);
    }

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _questionTextController.dispose();
    for (var controller in _answerControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz - Pregunta'),
        actions: [
          IconButton(icon: Icon(Icons.check), onPressed: _saveQuestion),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.quiz, color: Colors.purple),
                SizedBox(width: 8),
                Text(
                  'Quiz',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 20),
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
            ElevatedButton.icon(
              icon: Icon(Icons.image),
              label: Text('Añadir multimedia'),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MediaSelectionScreen(),
                  ),
                );
                if (result != null) setState(() => _selectedMediaId = result);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            SizedBox(height: 20),
            // TEMPORIZADOR SIMPLIFICADO - sin Switch que cause problemas
            Text(
              'Tiempo límite:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _timeLimit.toDouble(), // CAMBIADO
                    min: 5, // MÍNIMO 5 SEGUNDOS
                    max: 120,
                    divisions: 23,
                    label: '$_timeLimit segundos', // CAMBIADO
                    onChanged: (value) {
                      setState(() => _timeLimit = value.round()); // CAMBIADO
                    },
                  ),
                ),
                SizedBox(width: 16),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$_timeLimit s',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ), // CAMBIADO
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              'Mínimo: 5 segundos, Máximo: 120 segundos',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            SizedBox(height: 20),
            Text(
              'Puntaje de la pregunta:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => setState(() => _points = 500),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _points == 500 ? Colors.blue : Colors.grey[300],
                    foregroundColor:
                        _points == 500 ? Colors.white : Colors.black,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_border, size: 30),
                      SizedBox(height: 5),
                      Text('500 pts'),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => setState(() => _points = 1000),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _points == 1000 ? Colors.blue : Colors.grey[300],
                    foregroundColor:
                        _points == 1000 ? Colors.white : Colors.black,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_half, size: 30),
                      SizedBox(height: 5),
                      Text('1000 pts'),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => setState(() => _points = 2000),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _points == 2000 ? Colors.blue : Colors.grey[300],
                    foregroundColor:
                        _points == 2000 ? Colors.white : Colors.black,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, size: 30),
                      SizedBox(height: 5),
                      Text('2000 pts'),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
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
                          controller: _answerControllers[index],
                          decoration: InputDecoration(
                            labelText: 'Respuesta ${index + 1}',
                            border: InputBorder.none,
                          ),
                          onChanged: (value) => setState(
                            () => _answers[index] = Answer(
                              id: _answers[index].id,
                              text: value,
                              mediaId: _answers[index].mediaId,
                              isCorrect: _answers[index].isCorrect,
                            ),
                          ),
                        ),
                      ),
                      Checkbox(
                        value: answer.isCorrect,
                        onChanged: (value) => setState(
                          () => _answers[index] = Answer(
                            id: _answers[index].id,
                            text: _answers[index].text,
                            mediaId: _answers[index].mediaId,
                            isCorrect: value!,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
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
