import 'package:flutter/material.dart';
import 'package:kahoot_project/features/kahoot/domain/entities/question.dart';

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
        title: Text(
          question.text.isNotEmpty ? question.text : 'Pregunta ${index + 1}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.type == QuestionType.quiz ? 'Quiz' : 'Verdadero o Falso',
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