import 'option.dart';

class Slide {
  final String slideId;
  final String questionText;
  final int timeLimitSeconds;
  final List<Option> options;

  Slide({
    required this.slideId,
    required this.questionText,
    required this.timeLimitSeconds,
    required this.options,
  });
}
