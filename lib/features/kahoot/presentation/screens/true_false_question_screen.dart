import 'package:flutter/material.dart';
import 'package:green_frontend/features/kahoot/application/providers/kahoot_provider.dart';
import 'package:green_frontend/features/kahoot/domain/entities/answer.dart';
import 'package:green_frontend/features/kahoot/domain/entities/question.dart';
import 'package:provider/provider.dart';
import 'media_selection_screen.dart';

class TrueFalseQuestionScreen extends StatefulWidget {
  final int? questionIndex;

  const TrueFalseQuestionScreen({super.key, this.questionIndex});

  @override
  State<TrueFalseQuestionScreen> createState() =>
      _TrueFalseQuestionScreenState();
}

class _TrueFalseQuestionScreenState extends State<TrueFalseQuestionScreen> {
  final _questionTextController = TextEditingController();
  int _timeLimit = 20; // CAMBIADO: variable renombrada
  final List<Answer> _answers = [
    Answer(text: 'Verdadero', isCorrect: false),
    Answer(text: 'Falso', isCorrect: false),
  ];
  String? _selectedMediaId;
  int _points = 1000;

  @override
  void initState() {
    super.initState();
    if (widget.questionIndex != null) {
      _loadQuestion();
    }
  }

  void _loadQuestion() {
    final kahootProvider = Provider.of<KahootProvider>(context, listen: false);
    final question =
        kahootProvider.currentKahoot.questions[widget.questionIndex!];

    _questionTextController.text = question.text;
    _timeLimit = question.timeLimit; // CAMBIADO
    if (_timeLimit <= 0) _timeLimit = 20;

    _answers.clear();
    _answers.addAll(
      question.answers.map(
        (a) => Answer(
          id: a.id,
          text: a.text,
          mediaId: a.mediaId,
          isCorrect: a.isCorrect,
        ),
      ),
    );
    _selectedMediaId = question.mediaId;
    _points = question.points;
    if (_points <= 0) _points = 1000;
  }

  void _saveQuestion() {
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

    final kahootProvider = Provider.of<KahootProvider>(context, listen: false);
    final question = Question(
      id: widget.questionIndex != null
          ? kahootProvider.currentKahoot.questions[widget.questionIndex!].id
          : null,
      text: _questionTextController.text,
      mediaId: _selectedMediaId,
      timeLimit: _timeLimit, // CAMBIADO
      type: QuestionType.trueFalse,
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verdadero o Falso'),
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
                Icon(Icons.check_circle_outline, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Verdadero o Falso',
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
            // TEMPORIZADOR SIMPLIFICADO - sin Switch
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
            Text('Opciones:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Card(
              child: ListTile(
                title: Text(
                  'Verdadero',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Checkbox(
                  value: _answers[0].isCorrect,
                  onChanged: (value) => setState(() {
                    _answers[0].isCorrect = value!;
                    _answers[1].isCorrect = !value;
                  }),
                ),
              ),
            ),
            SizedBox(height: 8),
            Card(
              child: ListTile(
                title: Text(
                  'Falso',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Checkbox(
                  value: _answers[1].isCorrect,
                  onChanged: (value) => setState(() {
                    _answers[1].isCorrect = value!;
                    _answers[0].isCorrect = !value;
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
