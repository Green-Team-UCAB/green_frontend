import 'package:green_frontend/features/single_player/domain/entities/summary.dart';

class SummaryModel {
  final String attemptId;
  final int finalScore;
  final int totalCorrectAnswers;
  final int totalQuestions; 
  final double accuracyPercentage;

  SummaryModel({
    required this.attemptId,
    required this.finalScore,
    required this.totalCorrectAnswers,
    required this.totalQuestions,
    required this.accuracyPercentage,
  });

  factory SummaryModel.fromJson(Map<String, dynamic> json) {
    return SummaryModel(
      attemptId: json['attemptId'],
      finalScore: json['finalScore'],
      totalCorrectAnswers: json['totalCorrectAnswers'],
      totalQuestions: json['totalQuestions'],
      accuracyPercentage: json['accuracyPercentage'],
    );
  }

  Summary toEntity() {
    return Summary(
      attemptId: attemptId,
      finalScore: finalScore,
      totalCorrectAnswers: totalCorrectAnswers,
      totalQuestions: totalQuestions,
      accuracyPercentage: accuracyPercentage,
    );
  }
}