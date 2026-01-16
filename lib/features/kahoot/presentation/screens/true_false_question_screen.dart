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

  const TrueFalseQuestionScreen({super.key, this.questionIndex});

  @override
  State<TrueFalseQuestionScreen> createState() =>
      _TrueFalseQuestionScreenState();
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

  Map<int, String?> _answerMediaIds = {0: null, 1: null};
  Map<int, String?> _answerLocalPaths = {0: null, 1: null};

  // 🔴 NUEVO: Lista de tiempos permitidos basados en la imagen
  final List<int> allowedTimeLimits = [5, 10, 20, 30, 45, 60, 90, 120, 180, 240];
  
  // 🔴 NUEVO: Lista de puntos permitidos para preguntas Verdadero/Falso
  final List<int> allowedPoints = [0, 1000, 2000];

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
    
    // 🔴 MODIFICADO: Asegurar que el tiempo esté en la lista permitida
    _timeLimit = question.timeLimit;
    if (!allowedTimeLimits.contains(_timeLimit)) {
      _timeLimit = 20; // Valor por defecto si no está en la lista
    }

    _answers = question.answers
        .map((a) => Answer(
              id: a.id,
              text: a.text,
              mediaId: a.mediaId,
              isCorrect: a.isCorrect,
            ))
        .toList();

    _selectedMediaId = question.mediaId;
    
    // 🔴 MODIFICADO: Asegurar que los puntos estén en la lista permitida
    _points = question.points;
    if (!allowedPoints.contains(_points)) {
      _points = 1000; // Valor por defecto si no está en la lista
    }

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

          _answers[answerIndex] = _answers[answerIndex].copyWith(
            text: '',
            mediaId: media.id,
          );
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Imagen agregada a la respuesta.'),
            duration: Duration(seconds: 2),
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
        SnackBar(content: Text('Debe marcar una respuesta como correcta')),
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
                Text('Verdadero o Falso',
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

            _buildQuestionMediaSection(mediaProvider),

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
            
            // 🔴 MODIFICADO: Selector de puntos específicos para Verdadero/Falso
            Text('Puntaje de la pregunta:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTrueFalsePointsButton(0),
                _buildTrueFalsePointsButton(1000),
                _buildTrueFalsePointsButton(2000),
              ],
            ),
            SizedBox(height: 10),
            Text(
              'Solo puedes seleccionar: 0, 1000 o 2000 puntos',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            SizedBox(height: 20),
            
            Text('Opciones:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),

            _buildAnswerCard(0, 'Verdadero', mediaProvider),
            SizedBox(height: 8),

            _buildAnswerCard(1, 'Falso', mediaProvider),
          ],
        ),
      ),
    );
  }

  // 🔴 NUEVO: Botón de puntos específico para Verdadero/Falso
  Widget _buildTrueFalsePointsButton(int points) {
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
            points == 1000 ? Icons.star_half : Icons.star,
            size: 30,
          ),
          SizedBox(height: 5),
          Text('$points pts'),
        ],
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

  Widget _buildAnswerCard(int index, String text, MediaProvider mediaProvider) {
    final hasMedia = _answerMediaIds[index] != null;
    final localPath = _answerLocalPaths[index];
    final isCorrect = _answers[index].isCorrect;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(
              hasMedia ? '$text (con imagen)' : text,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: Checkbox(
              value: isCorrect,
              onChanged: (value) => setState(() {
                _answers[index] = _answers[index].copyWith(
                  isCorrect: value!,
                );
                final otherIndex = index == 0 ? 1 : 0;
                _answers[otherIndex] = _answers[otherIndex].copyWith(
                  isCorrect: !value!,
                );
              }),
            ),
          ),

          if (hasMedia && localPath != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
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
            ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (hasMedia)
                  Expanded(
                    child: Text(
                      'Esta respuesta tiene imagen. El texto se ha deshabilitado.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange[700],
                      ),
                    ),
                  ),
                TextButton.icon(
                  icon: Icon(hasMedia ? Icons.image : Icons.add_photo_alternate),
                  label: Text(hasMedia ? 'Cambiar imagen' : 'Agregar imagen'),
                  onPressed: () {
                    if (hasMedia) {
                      _addMediaToAnswer(index);
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Agregar imagen'),
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
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}