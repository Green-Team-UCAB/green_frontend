import 'dart:io';
import 'package:flutter/material.dart';
import 'package:green_frontend/features/kahoot/application/providers/kahoot_provider.dart';
import 'package:green_frontend/features/kahoot/domain/entities/answer.dart';
import 'package:green_frontend/features/kahoot/domain/entities/question.dart';
import 'package:provider/provider.dart';
import 'media_selection_screen.dart';
import 'package:green_frontend/features/media/application/providers/media_provider.dart';

class NormalQuestionScreen extends StatefulWidget {
  final int? questionIndex;

  const NormalQuestionScreen({Key? key, this.questionIndex}) : super(key: key);

  @override
  _NormalQuestionScreenState createState() => _NormalQuestionScreenState();
}

class _NormalQuestionScreenState extends State<NormalQuestionScreen> {
  final _questionTextController = TextEditingController();
  int _timeLimit = 20;
  List<Answer> _answers = [];
  List<TextEditingController> _answerControllers = [];
  String? _selectedMediaId;
  int _points = 1000;

  Map<int, String?> _answerMediaIds = {};
  Map<int, String?> _answerLocalPaths = {};

  // 🔴 NUEVO: Lista de tiempos permitidos basados en la imagen
  final List<int> allowedTimeLimits = [5, 10, 20, 30, 45, 60, 90, 120, 180, 240];
  
  // 🔴 NUEVO: Lista de puntos permitidos para preguntas Quiz
  final List<int> allowedPoints = [0, 500, 1000];

  @override
  void initState() {
    super.initState();
    if (widget.questionIndex != null) {
      _loadQuestion();
    } else {
      for (int i = 0; i < 4; i++) {
        _answers.add(Answer(text: '', isCorrect: false));
        _answerControllers.add(TextEditingController());
        _answerMediaIds[i] = null;
        _answerLocalPaths[i] = null;
      }
    }
  }

  void _loadQuestion() {
    final kahootProvider = Provider.of<KahootProvider>(context, listen: false);
    final mediaProvider = Provider.of<MediaProvider>(context, listen: false);

    final question =
        kahootProvider.currentKahoot.questions[widget.questionIndex!];

    _questionTextController.text = question.text;
    
    // 🔴 MODIFICADO: Asegurar que el tiempo esté en la lista permitida
    _timeLimit = question.timeLimit;
    if (!allowedTimeLimits.contains(_timeLimit)) {
      _timeLimit = 20; // Valor por defecto si no está en la lista
    }

    _selectedMediaId = question.mediaId;
    
    // 🔴 MODIFICADO: Asegurar que los puntos estén en la lista permitida
    _points = question.points;
    if (!allowedPoints.contains(_points)) {
      _points = 1000; // Valor por defecto si no está en la lista
    }

    _answers.clear();
    _answerControllers.clear();
    _answerMediaIds.clear();
    _answerLocalPaths.clear();

    for (var i = 0; i < question.answers.length; i++) {
      final answer = question.answers[i];
      _answers.add(Answer(
        id: answer.id,
        text: answer.text,
        mediaId: answer.mediaId,
        isCorrect: answer.isCorrect,
      ));
      _answerControllers.add(TextEditingController(text: answer.text));
      _answerMediaIds[i] = answer.mediaId;

      if (answer.mediaId != null && answer.mediaId!.isNotEmpty) {
        _answerLocalPaths[i] = mediaProvider.getLocalPath(answer.mediaId!);
      } else {
        _answerLocalPaths[i] = null;
      }
    }
  }

  void _addAnswer() {
    setState(() {
      final newIndex = _answers.length;
      _answers.add(Answer(text: '', isCorrect: false));
      _answerControllers.add(TextEditingController());
      _answerMediaIds[newIndex] = null;
      _answerLocalPaths[newIndex] = null;
    });
  }

  Future<void> _addMediaToAnswer(int answerIndex) async {
    final mediaProvider = Provider.of<MediaProvider>(context, listen: false);

    try {
      final media = await mediaProvider.pickImageFromGallery();
      if (media != null) {
        setState(() {
          _answerControllers[answerIndex].clear();
          
          _answerMediaIds[answerIndex] = media.id;
          _answerLocalPaths[answerIndex] = media.localPath;

          _answers[answerIndex] = _answers[answerIndex].copyWith(
            text: '',
            mediaId: media.id,
          );
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Imagen agregada. Recuerda que no puedes tener texto e imagen en la misma respuesta.'),
            duration: Duration(seconds: 3),
          ),
        );
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

    // 🔴 NUEVO: Validar que el tiempo esté en la lista permitida
    if (!allowedTimeLimits.contains(_timeLimit)) {
      _timeLimit = 20;
    }

    for (var i = 0; i < _answers.length; i++) {
      final answer = _answers[i];
      final hasText = answer.text != null && answer.text!.isNotEmpty;
      final hasMedia = answer.mediaId != null && answer.mediaId!.isNotEmpty;
      
      if (!hasText && !hasMedia) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('La respuesta ${i + 1} debe tener texto o imagen')),
        );
        return;
      }
      
      if (hasText && hasMedia) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('La respuesta ${i + 1} no puede tener texto e imagen simultáneamente'),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }
    }

    final hasCorrectAnswer = _answers.any((answer) => answer.isCorrect);
    if (!hasCorrectAnswer) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Debe marcar al menos una respuesta como correcta')),
      );
      return;
    }

    for (var i = 0; i < _answers.length; i++) {
      final hasText = _answers[i].text != null && _answers[i].text!.isNotEmpty;
      final hasMedia = _answerMediaIds[i] != null;
      
      if (!hasText && !hasMedia) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('La respuesta ${i + 1} no puede estar vacía. Agrega texto o imagen.')),
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
      timeLimit: _timeLimit,
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
    final mediaProvider = Provider.of<MediaProvider>(context);

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
                Text('Quiz',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

            _buildQuestionMediaSection(),

            // 🔴 MODIFICADO: Selector de tiempo con valores específicos
            SizedBox(height: 20),
            Text('Tiempo límite:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            DropdownButtonFormField<int>(
              value: _timeLimit,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              items: allowedTimeLimits.map((time) {
                return DropdownMenuItem<int>(
                  value: time,
                  child: Text('$time segundos'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _timeLimit = value!;
                });
              },
            ),
            SizedBox(height: 20),
            
            // 🔴 MODIFICADO: Selector de puntos específicos para Quiz
            Text('Puntaje de la pregunta:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuizPointsButton(0),
                _buildQuizPointsButton(500),
                _buildQuizPointsButton(1000),
              ],
            ),
            SizedBox(height: 10),
            Text(
              'Solo puedes seleccionar: 0, 500 o 1000 puntos',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            SizedBox(height: 20),
            
            Text('Respuestas:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            ..._answers.asMap().entries.map((entry) {
              final index = entry.key;
              final answer = entry.value;
              return _buildAnswerCard(index, answer, mediaProvider);
            }).toList(),
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

  // 🔴 NUEVO: Botón de puntos específico para Quiz
  Widget _buildQuizPointsButton(int points) {
    return ElevatedButton(
      onPressed: () => setState(() => _points = points),
      style: ElevatedButton.styleFrom(
        backgroundColor: _points == points ? Colors.blue : Colors.grey[300],
        foregroundColor: _points == points ? Colors.white : Colors.black,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            points == 0 ? Icons.star_border :
            points == 500 ? Icons.star_half : Icons.star,
            size: 30,
          ),
          SizedBox(height: 5),
          Text('$points pts'),
        ],
      ),
    );
  }

  Widget _buildQuestionMediaSection() {
    final mediaProvider = Provider.of<MediaProvider>(context, listen: false);
    final localPath = _selectedMediaId != null
        ? mediaProvider.getLocalPath(_selectedMediaId!)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Multimedia de la pregunta:',
            style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 10),

        if (_selectedMediaId != null && localPath != null)
          Container(
            margin: EdgeInsets.only(bottom: 10),
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
              color: Colors.grey[100],
            ),
            child: Stack(
              children: [
                Center(
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: 180,
                      maxWidth: double.infinity,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(localPath),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: Icon(Icons.broken_image,
                                  size: 40, color: Colors.grey),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedMediaId = null;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                      padding: EdgeInsets.all(6),
                      child: Icon(Icons.close,
                          color: Colors.white, size: 18),
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

  Widget _buildAnswerCard(
      int index, Answer answer, MediaProvider mediaProvider) {
    final hasMedia = _answerMediaIds[index] != null;
    final localPath = _answerLocalPaths[index];

    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _answerControllers[index],
                    decoration: InputDecoration(
                      labelText: 'Respuesta ${index + 1}',
                      border: InputBorder.none,
                      hintText: hasMedia 
                        ? 'Imagen seleccionada (no se puede agregar texto)' 
                        : 'Ingresa el texto',
                      enabled: !hasMedia,
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty && hasMedia) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Cambiar a texto'),
                            content: Text('Al agregar texto se eliminará la imagen de esta respuesta. ¿Continuar?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () {
                                  _removeMediaFromAnswer(index);
                                  setState(() => _answers[index] = Answer(
                                    id: _answers[index].id,
                                    text: value,
                                    mediaId: null,
                                    isCorrect: _answers[index].isCorrect,
                                  ));
                                  Navigator.pop(context);
                                },
                                child: Text('Continuar'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        setState(() => _answers[index] = Answer(
                          id: _answers[index].id,
                          text: value,
                          mediaId: null,
                          isCorrect: _answers[index].isCorrect,
                        ));
                      }
                    },
                  ),
                ),
                Checkbox(
                  value: answer.isCorrect,
                  onChanged: (value) => setState(() => _answers[index] = Answer(
                    id: _answers[index].id,
                    text: _answers[index].text,
                    mediaId: _answers[index].mediaId,
                    isCorrect: value!,
                  )),
                ),
              ],
            ),

            if (hasMedia && localPath != null)
              Container(
                margin: EdgeInsets.only(top: 8),
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                  color: Colors.grey[50],
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Container(
                        constraints: BoxConstraints(
                          maxHeight: 100,
                          maxWidth: double.infinity,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(localPath),
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: Center(
                                  child:
                                      Icon(Icons.broken_image, size: 30, color: Colors.grey),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 5,
                      right: 5,
                      child: GestureDetector(
                        onTap: () => _removeMediaFromAnswer(index),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            shape: BoxShape.circle,
                          ),
                          padding: EdgeInsets.all(4),
                          child:
                              Icon(Icons.close, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                icon: Icon(hasMedia ? Icons.image : Icons.add_photo_alternate),
                label: Text(
                  hasMedia ? 'Cambiar imagen' : 'Agregar imagen',
                  style: TextStyle(
                    color: _answerControllers[index].text.isNotEmpty 
                      ? Colors.grey 
                      : null,
                  ),
                ),
                onPressed: () {
                  if (_answerControllers[index].text.isNotEmpty) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Cambiar a imagen'),
                        content: Text('Al agregar una imagen se eliminará el texto de esta respuesta. ¿Continuar?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _addMediaToAnswer(index);
                            },
                            child: Text('Continuar'),
                          ),
                        ],
                      ),
                    );
                  } else {
                    _addMediaToAnswer(index);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}