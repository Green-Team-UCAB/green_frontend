import 'package:flutter/material.dart';
import 'package:green_frontend/features/kahoot/domain/entities/question.dart';

class QuestionTile extends StatelessWidget {
  final Question question;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const QuestionTile({
    Key? key,
    required this.question,
    required this.index,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Contar respuestas con multimedia
    int answersWithMedia = question.answers.where((a) => a.mediaId != null && a.mediaId!.isNotEmpty).length;
    bool hasQuestionMedia = question.mediaId != null && question.mediaId!.isNotEmpty;

    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: question.type == QuestionType.quiz ? Colors.purple : Colors.green,
          child: Text(
            (index + 1).toString(),
            style: TextStyle(color: Colors.white),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                question.text.isNotEmpty ? question.text : 'Pregunta ${index + 1}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (hasQuestionMedia)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(Icons.image, size: 16, color: Colors.blue),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  question.type == QuestionType.quiz ? 'Quiz' : 'V/F',
                  style: TextStyle(fontSize: 12),
                ),
                SizedBox(width: 8),
                if (answersWithMedia > 0)
                  Row(
                    children: [
                      Icon(Icons.image, size: 12, color: Colors.green),
                      SizedBox(width: 2),
                      Text(
                        '$answersWithMedia',
                        style: TextStyle(fontSize: 10, color: Colors.green),
                      ),
                    ],
                  ),
                SizedBox(width: 8),
                Icon(Icons.timer, size: 12),
                SizedBox(width: 2),
                Text(
                  '${question.timeLimit}s',
                  style: TextStyle(fontSize: 10),
                ),
                SizedBox(width: 8),
                Icon(Icons.star, size: 12, color: Colors.amber),
                SizedBox(width: 2),
                Text(
                  '${question.points} pts',
                  style: TextStyle(fontSize: 10),
                ),
              ],
            ),
            if (question.id != null)
              Text(
                'ID: ${question.id!.substring(0, 8)}...',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
        onTap: onTap,
      ),
    );
  }
}