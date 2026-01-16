// domain/entities/option.dart
class Option {
  final int index;
  final String text;
  final String? mediaUrl;

  Option({
    required this.index,
    required this.text,
    this.mediaUrl,
  });
}