import 'package:green_frontend/features/single_player/domain/entities/option.dart';

enum QuestionType {
  singleChoice,
  multipleChoice,
}

class Slide {
  final String slideId;
  final QuestionType questionType;
  final String questionText;
  final int timeLimitSeconds;
  final String? mediaId;
  final List<Option> options;

  Slide({
    required this.slideId,
    required this.questionType,
    required this.questionText,
    required this.timeLimitSeconds,
    this.mediaId,
    required this.options,
  });
}
