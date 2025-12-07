import 'package:equatable/equatable.dart';

class ReportDetail extends Equatable {
  final String kahootId;
  final String title;
  final int finalScore;
  final int correctAnswers;
  final int totalQuestions;
  final int averageTimeMs;
  final int? rankingPosition;
  final List<QuestionResult> questions;

  const ReportDetail({
    required this.kahootId,
    required this.title,
    required this.finalScore,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.averageTimeMs,
    this.rankingPosition,
    required this.questions,
  });

  @override
  List<Object?> get props => [kahootId, title, finalScore, questions];
}

class QuestionResult extends Equatable {
  final int questionIndex;
  final String questionText;
  final bool isCorrect;
  final int timeTakenMs;

  // NUEVOS CAMPOS
  final List<String>? answerText; // Array de textos seleccionados
  final List<String>? answerImages; // Array de URLs de imágenes seleccionadas

  const QuestionResult({
    required this.questionIndex,
    required this.questionText,
    required this.isCorrect,
    required this.timeTakenMs,
    this.answerText,
    this.answerImages,
  });

  @override
  List<Object?> get props => [
    questionIndex,
    isCorrect,
    answerText,
    answerImages,
  ];
}
