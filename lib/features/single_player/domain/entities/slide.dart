import 'package:green_frontend/features/single_player/domain/entities/option.dart';

enum QuestionType {
  singleChoice,
  multipleChoice,
  trueFalse,
}

class Slide {
  final String slideId;
  final QuestionType questionType;
  final String questionText;
  final int timeLimitSeconds;
  final String? mediaID;
  final List<Option> options;

  Slide({
    required this.slideId,
    required this.questionType,
    required this.questionText,
    required this.timeLimitSeconds,
    this.mediaID,
    required this.options,
  });
}
