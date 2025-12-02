import 'package:green_frontend/features/single_player/domain/entities/answer_result.dart';
import'package:green_frontend/features/single_player/domain/entities/attempt.dart';
import 'package:green_frontend/features/single_player/infraestructure/models/slide_model.dart';

class AnswerResultModel {
  final bool wasCorrect;
  final int pointsEarned;
  final int updatedScore;
  final AttemptState attemptState;
  final SlideModel? nextSlide;

  AnswerResultModel({
    required this.wasCorrect,
    required this.pointsEarned,
    required this.updatedScore,
    required this.attemptState,
    this.nextSlide,
  });

  factory AnswerResultModel.fromJson(Map<String, dynamic> json) {
  bool parseBool(dynamic v) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      final s = v.toLowerCase().trim();
      return s == 'true';
    }
    return false;
  }

  int parseInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  AttemptState parseState(dynamic v) {
    if (v == null) return AttemptState.unknown;
    final s = v.toString().toLowerCase().trim();
    if (s == 'in_progress' || s == 'inprogress' || s == 'in-progress') return AttemptState.inProgress;
    if (s == 'completed' || s == 'done') return AttemptState.completed;
    return AttemptState.unknown;
  }

  final wasCorrect = parseBool(json['wasCorrect']);
  final pointsEarned = parseInt(json['pointsEarned']);
  final updatedScore = parseInt(json['updatedScore']);
  final attemptState = parseState(json['attemptState']);

  final nextSlideJson = json['nextSlide'];
  final nextSlide = (nextSlideJson is Map<String, dynamic>)
      ? SlideModel.fromJson(nextSlideJson)
      : null;

  return AnswerResultModel(
    wasCorrect: wasCorrect,
    pointsEarned: pointsEarned,
    updatedScore: updatedScore,
    attemptState: attemptState,
    nextSlide: nextSlide,
  );
}


  AnswerResult toEntity() {
    return AnswerResult(
      wasCorrect: wasCorrect,
      pointsEarned: pointsEarned,
      updatedScore: updatedScore,
      attemptState: attemptState,
      nextSlide: nextSlide?.toEntity(),
    );
  }


}