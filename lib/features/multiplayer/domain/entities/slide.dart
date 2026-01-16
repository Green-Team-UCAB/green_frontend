import 'package:green_frontend/features/multiplayer/domain/entities/slide_option.dart';

enum QuestionType { single, multiple, trueFalse}


class Slide {
  final String id;
  final int position;
  final String slideType;
  final int timeLimitSeconds;
  final String questionText;
  final String? slideImageUrl;
  final int pointsValue;
  final List<Option> options;

  Slide({
    required this.id,
    required this.position,
    required this.slideType,
    required this.timeLimitSeconds,
    required this.questionText,
    required this.slideImageUrl,
    required this.pointsValue,
    required this.options,
  });
}