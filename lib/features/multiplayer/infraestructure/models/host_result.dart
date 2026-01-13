import 'package:green_frontend/features/multiplayer/domain/entities/host_result.dart';
import 'package:green_frontend/features/multiplayer/infraestructure/models/leaderboard_model.dart';

class HostResultModel extends HostResults {
  const HostResultModel({
    required super.correctAnswerIds,
    required super.leaderboard,
    required super.distributionTop3,
    required super.currentQuestion,
    required super.totalQuestions,
    required super.isLastSlide,
  });

  factory HostResultModel.fromJson(Map<String, dynamic> json) {
    return HostResultModel(
      correctAnswerIds:
          List<String>.from(json['correctAnswerIds'] as List<dynamic>),
      leaderboard: (json['leaderboard'] as List<dynamic>)
          .map((entry) => LeaderboardModel.fromJson(entry as Map<String, dynamic>))
          .toList(),
      distributionTop3: Map<String, int>.from(json['distributionTop3'] as Map),
      currentQuestion: json['currentQuestion'] as int,
      totalQuestions: json['totalQuestions'] as int,
      isLastSlide: json['isLastSlide'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'correctAnswerIds': correctAnswerIds,
      'leaderboard': leaderboard
          .map((entry) => (entry as LeaderboardModel).toJson())
          .toList(),
      'distributionTop3': distributionTop3,
      'currentQuestion': currentQuestion,
      'totalQuestions': totalQuestions,
      'isLastSlide': isLastSlide,
    };
  }
}