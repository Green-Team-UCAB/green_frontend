import 'package:green_frontend/features/single_player/domain/entities/answer.dart';

class AnswerModel {
  final String slideId;
  final List<int>? answerIndex;
  final int? timeElapsedSeconds;

  AnswerModel({
    required this.slideId,
    this.answerIndex,
    this.timeElapsedSeconds,
  });

factory AnswerModel.fromEntity(Answer answer) {
    return AnswerModel(
      slideId: answer.slideId,
      answerIndex: answer.answerIndex == null ? null : List<int>.from(answer.answerIndex!),
      timeElapsedSeconds: answer.timeElapsedSeconds,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'slideId': slideId};
    if (answerIndex != null) {
      map['answerIndex'] = answerIndex;
    }
    if (timeElapsedSeconds != null) {
      map['timeElapsedSeconds'] = timeElapsedSeconds;
    } 
    return map;
  }

}