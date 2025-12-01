import 'package:flutter/material.dart';

class SummaryPage extends StatelessWidget {
  final int score;

  const SummaryPage({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Score')),
      body: Center(
        child: Text('Your score is: $score', style: const TextStyle(fontSize: 24)),
      ),
    );
  }
}