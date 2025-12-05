import 'package:green_frontend/features/single_player/domain/entities/answer.dart';

class AnswerModel extends Answer {
  AnswerModel({
    required super.slideId,
    super.answerIndex,
    super.timeElapsedSeconds,
  });

factory AnswerModel.fromEntity(Answer answer) {
    return AnswerModel(
      slideId: answer.slideId,
      answerIndex: answer.answerIndex == null ? null : List<int>.from(answer.answerIndex!),
      timeElapsedSeconds: answer.timeElapsedSeconds,
    );
  }

    Map<String, dynamic> toJson() => {
    'slideId': slideId,
    'answerIndex': answerIndex ?? [],
    'timeElapsedSeconds': timeElapsedSeconds ?? 0,
  };

}