import 'dart:io';
import 'package:flutter/material.dart';
import 'package:green_frontend/features/kahoot/application/providers/kahoot_provider.dart';
import 'package:green_frontend/features/kahoot/domain/entities/answer.dart';
import 'package:green_frontend/features/kahoot/domain/entities/question.dart';
import 'package:provider/provider.dart';
import 'media_selection_screen.dart';
import 'package:green_frontend/features/media/application/providers/media_provider.dart';

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
  int _points = 1000;
  
  // Multimedia para respuestas
  Map<int, String?> _answerMediaIds = {0: null, 1: null};
  Map<int, String?> _answerLocalPaths = {0: null, 1: null};

  @override
  void initState() {
    super.initState();
    if (widget.questionIndex != null) {
      _loadQuestion();
    }
  }

  void _loadQuestion() {
    final kahootProvider = Provider.of<KahootProvider>(context, listen: false);
    final mediaProvider = Provider.of<MediaProvider>(context, listen: false);
    
    final question =
        kahootProvider.currentKahoot.questions[widget.questionIndex!];

    _questionTextController.text = question.text;
    _timeLimit = question.timeLimit;
    if (_timeLimit <= 0) _timeLimit = 20;

    _answers = question.answers.map((a) => Answer(
      id: a.id,
      text: a.text,
      mediaId: a.mediaId,
      isCorrect: a.isCorrect,
    )).toList();

    _selectedMediaId = question.mediaId;
    _points = question.points;
    if (_points <= 0) _points = 1000;
    
    // Cargar multimedia de respuestas
    for (var i = 0; i < _answers.length; i++) {
      _answerMediaIds[i] = _answers[i].mediaId;
      if (_answers[i].mediaId != null && _answers[i].mediaId!.isNotEmpty) {
        _answerLocalPaths[i] = mediaProvider.getLocalPath(_answers[i].mediaId!);
      } else {
        _answerLocalPaths[i] = null;
      }
    }
  }

  Future<void> _addMediaToAnswer(int answerIndex) async {
    final mediaProvider = Provider.of<MediaProvider>(context, listen: false);
    
    try {
      final media = await mediaProvider.pickImageFromGallery();
      if (media != null) {
        setState(() {
          _answerMediaIds[answerIndex] = media.id;
          _answerLocalPaths[answerIndex] = media.localPath;
          
          // Actualizar la respuesta en la lista
          _answers[answerIndex] = _answers[answerIndex].copyWith(
            mediaId: media.id,
          );
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al agregar imagen: $e')),
      );
    }
  }

  void _removeMediaFromAnswer(int answerIndex) {
    setState(() {
      _answerMediaIds[answerIndex] = null;
      _answerLocalPaths[answerIndex] = null;
      
      _answers[answerIndex] = _answers[answerIndex].copyWith(
        mediaId: null,
      );
    });
  }

  void _saveQuestion() {
    if (_questionTextController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, ingresa la pregunta')),
      );
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
      timeLimit: _timeLimit,
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
    final mediaProvider = Provider.of<MediaProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Verdadero o Falso'),
        actions: [IconButton(icon: Icon(Icons.check), onPressed: _saveQuestion)],
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
                Text('Verdadero o Falso',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
            
            // Multimedia para la pregunta
            _buildQuestionMediaSection(mediaProvider),
            
            SizedBox(height: 20),
            Text('Tiempo límite:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _timeLimit.toDouble(),
                    min: 5,
                    max: 120,
                    divisions: 23,
                    label: '$_timeLimit segundos',
                    onChanged: (value) {
                      setState(() => _timeLimit = value.round());
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
                  child: Text('$_timeLimit s',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text('Mínimo: 5 segundos, Máximo: 120 segundos',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            SizedBox(height: 20),
            Text('Puntaje de la pregunta:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPointsButton(500, Icons.star_border),
                _buildPointsButton(1000, Icons.star_half),
                _buildPointsButton(2000, Icons.star),
              ],
            ),
            SizedBox(height: 20),
            Text('Opciones:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            
            // Opción Verdadero con multimedia
            _buildAnswerCard(0, 'Verdadero', mediaProvider),
            SizedBox(height: 8),
            
            // Opción Falso con multimedia
            _buildAnswerCard(1, 'Falso', mediaProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionMediaSection(MediaProvider mediaProvider) {
    final localPath = _selectedMediaId != null 
        ? mediaProvider.getLocalPath(_selectedMediaId!)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Multimedia de la pregunta:', 
            style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        
        // Mostrar imagen si existe
        if (_selectedMediaId != null && localPath != null)
          Container(
            margin: EdgeInsets.only(bottom: 10),
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(localPath),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: Center(
                          child: Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 5,
                  right: 5,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedMediaId = null;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.close, color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        
        ElevatedButton.icon(
          icon: Icon(Icons.image),
          label: Text(_selectedMediaId == null 
              ? 'Añadir multimedia' 
              : 'Cambiar multimedia'),
          onPressed: () async {
            final result = await Navigator.push<String?>(
              context,
              MaterialPageRoute(
                builder: (context) => MediaSelectionScreen(
                  currentMediaId: _selectedMediaId,
                  onMediaSelected: (mediaId) {
                    setState(() => _selectedMediaId = mediaId);
                  },
                ),
              ),
            );
            
            if (result != null) {
              setState(() => _selectedMediaId = result);
            }
          },
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 50),
          ),
        ),
      ],
    );
  }

  Widget _buildPointsButton(int points, IconData icon) {
    return ElevatedButton(
      onPressed: () => setState(() => _points = points),
      style: ElevatedButton.styleFrom(
        backgroundColor: _points == points ? Colors.blue : Colors.grey[300],
        foregroundColor: _points == points ? Colors.white : Colors.black,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 30),
          SizedBox(height: 5),
          Text('$points pts'),
        ],
      ),
    );
  }

  Widget _buildAnswerCard(int index, String text, MediaProvider mediaProvider) {
    final hasMedia = _answerMediaIds[index] != null;
    final localPath = _answerLocalPaths[index];
    final isCorrect = _answers[index].isCorrect;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(text, style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: Checkbox(
              value: isCorrect,
              onChanged: (value) => setState(() {
                _answers[index] = _answers[index].copyWith(
                  isCorrect: value!,
                );
                // Asegurar que solo una opción esté marcada
                final otherIndex = index == 0 ? 1 : 0;
                _answers[otherIndex] = _answers[otherIndex].copyWith(
                  isCorrect: !value!,
                );
              }),
            ),
          ),
          
          // Imagen de la respuesta
          if (hasMedia && localPath != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                height: 80,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(localPath),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: Icon(Icons.broken_image, color: Colors.grey),
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      top: 5,
                      right: 5,
                      child: GestureDetector(
                        onTap: () => _removeMediaFromAnswer(index),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.close, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Botón para agregar multimedia
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                icon: Icon(hasMedia ? Icons.image : Icons.add_photo_alternate),
                label: Text(hasMedia ? 'Cambiar imagen' : 'Agregar imagen'),
                onPressed: () => _addMediaToAnswer(index),
              ),
            ),
          ),
        ],
      ),
    );
  }
}