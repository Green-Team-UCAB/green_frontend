import 'package:equatable/equatable.dart';

class SessionReport extends Equatable {
  final String reportId;
  final String sessionId;
  final String title;
  final DateTime executionDate;
  final List<PlayerRanking> playerRanking;
  final List<QuestionAnalysis> questionAnalysis;

  const SessionReport({
    required this.reportId,
    required this.sessionId,
    required this.title,
    required this.executionDate,
    required this.playerRanking,
    required this.questionAnalysis,
  });

  @override
  List<Object?> get props => [
    reportId,
    sessionId,
    title,
    executionDate,
    playerRanking,
    questionAnalysis,
  ];
}

class PlayerRanking extends Equatable {
  final int position;
  final String username;
  final int score;
  final int correctAnswers;

  const PlayerRanking({
    required this.position,
    required this.username,
    required this.score,
    required this.correctAnswers,
  });

  @override
  List<Object?> get props => [position, username, score, correctAnswers];
}

class QuestionAnalysis extends Equatable {
  final int questionIndex;
  final String questionText;
  final double correctPercentage; // 0.0 a 1.0

  const QuestionAnalysis({
    required this.questionIndex,
    required this.questionText,
    required this.correctPercentage,
  });

  @override
  List<Object?> get props => [questionIndex, questionText, correctPercentage];
}
