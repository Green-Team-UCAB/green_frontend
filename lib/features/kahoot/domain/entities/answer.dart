class Answer {
  String? id;
  String? text;
  String? mediaId;
  bool isCorrect;

  Answer({
    this.id,
    this.text,
    this.mediaId,
    required this.isCorrect,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'mediaId': mediaId,
      'isCorrect': isCorrect,
    };
  }
}