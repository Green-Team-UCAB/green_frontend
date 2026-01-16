class SlideOption {
  final String index;
  final String? text;
  final String? mediaUrl;
  final bool isCorrect;

  const SlideOption(
      {required this.index, this.text, this.mediaUrl, this.isCorrect = false});
}
