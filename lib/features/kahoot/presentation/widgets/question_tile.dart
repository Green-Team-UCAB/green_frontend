import 'package:flutter/material.dart';
import 'package:green_frontend/features/kahoot/domain/entities/question.dart';

class QuestionTile extends StatelessWidget {
  final Question question;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback? onDuplicate; // ✅ NUEVO: para duplicar
  final VoidCallback? onChangePoints; // ✅ NUEVO: para cambiar puntuación

  const QuestionTile({
    Key? key,
    required this.question,
    required this.index,
    required this.onTap,
    required this.onDelete,
    this.onDuplicate,
    this.onChangePoints,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Contar respuestas con multimedia
    int answersWithMedia = question.answers
        .where((a) => a.mediaId != null && a.mediaId!.isNotEmpty)
        .length;
    bool hasQuestionMedia =
        question.mediaId != null && question.mediaId!.isNotEmpty;

    return Container(
      key: key,
      margin: EdgeInsets.only(bottom: 8),
      child: Card(
        child: InkWell(
          onTap: onTap, // 🔴 AGREGADO: Esto permite que toda la tarjeta sea tappable
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ NUEVO: Header con botones de acción
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: question.type == QuestionType.quiz 
                            ? Colors.purple 
                            : Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          (index + 1).toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        question.text.isNotEmpty
                            ? question.text
                            : 'Pregunta ${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // ✅ NUEVO: Botones de acción
                    if (onChangePoints != null)
                      IconButton(
                        icon: Icon(Icons.trending_up, size: 20),
                        color: Colors.orange,
                        tooltip: 'Cambiar puntuación',
                        onPressed: onChangePoints,
                      ),
                    if (onDuplicate != null)
                      IconButton(
                        icon: Icon(Icons.content_copy, size: 20),
                        color: Colors.blue,
                        tooltip: 'Duplicar pregunta',
                        onPressed: onDuplicate,
                      ),
                    IconButton(
                      icon: Icon(Icons.delete, size: 20),
                      color: Colors.red,
                      tooltip: 'Eliminar pregunta',
                      onPressed: onDelete,
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Información detallada
                Row(
                  children: [
                    Chip(
                      label: Text(
                        question.type == QuestionType.quiz ? 'Quiz' : 'V/F',
                        style: TextStyle(fontSize: 10, color: Colors.white),
                      ),
                      backgroundColor: question.type == QuestionType.quiz 
                          ? Colors.purple 
                          : Colors.green,
                    ),
                    const SizedBox(width: 8),
                    if (hasQuestionMedia)
                      Chip(
                        label: Row(
                          children: [
                            Icon(Icons.image, size: 12),
                            const SizedBox(width: 4),
                            Text('Multimedia', style: TextStyle(fontSize: 10)),
                          ],
                        ),
                        backgroundColor: Colors.blue[50],
                      ),
                    if (answersWithMedia > 0)
                      Chip(
                        label: Row(
                          children: [
                            Icon(Icons.image, size: 12, color: Colors.green),
                            const SizedBox(width: 4),
                            Text('$answersWithMedia', style: TextStyle(fontSize: 10)),
                          ],
                        ),
                        backgroundColor: Colors.green[50],
                      ),
                    const SizedBox(width: 8),
                    Icon(Icons.timer, size: 12, color: Colors.grey[600]),
                    const SizedBox(width: 2),
                    Text(
                      '${question.timeLimit}s',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.star, size: 12, color: Colors.amber),
                    const SizedBox(width: 2),
                    Text(
                      '${question.points} pts',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
                
                if (question.id != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'ID: ${question.id!.substring(0, 8)}...',
                      style: TextStyle(fontSize: 9, color: Colors.grey[500]),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}