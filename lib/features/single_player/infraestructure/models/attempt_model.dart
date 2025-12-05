import 'package:green_frontend/features/single_player/infraestructure/models/slide_model.dart';
import 'package:green_frontend/features/single_player/domain/entities/attempt.dart';

class AttemptModel {
  final String attemptId;
  final String? state;
  final int currentScore;
  final SlideModel? nextSlide;

  AttemptModel({
    required this.attemptId,
    required this.state,
    required this.currentScore,
    this.nextSlide,
  });

factory AttemptModel.fromJson(Map<String, dynamic> json) {
    return AttemptModel(
      attemptId: json['attemptId'],
      state: json['state'] as String?,
      currentScore: json['currentScore'] ?? 0,
      nextSlide: json['firstSlide'] != null
          ? SlideModel.fromJson(json['firstSlide'])
          : null,
    );
  }

  Attempt toEntity() {
    return Attempt(
      attemptId: attemptId,
      state: AttemptState.values.firstWhere(
          (e) => e.toString().split('.').last == state,
          orElse: () => AttemptState.inProgress),
      currentScore: currentScore,
      nextSlide: nextSlide?.toEntity(),
    );
  }
}