class Answer {
  String? id;
  String? text;
  String? mediaId;
  String? localMediaPath; // Nueva propiedad para ruta local
  bool isCorrect;

  Answer({
    this.id,
    this.text,
    this.mediaId,
    this.localMediaPath,
    required this.isCorrect,
  });

  // Método para obtener la ruta de la imagen a mostrar
  String? get displayImagePath {
    return localMediaPath ?? mediaId;
  }

  Answer copyWith({
    String? id,
    String? text,
    String? mediaId,
    String? localMediaPath,
    bool? isCorrect,
  }) {
    return Answer(
      id: id ?? this.id,
      text: text ?? this.text,
      mediaId: mediaId ?? this.mediaId,
      localMediaPath: localMediaPath ?? this.localMediaPath,
      isCorrect: isCorrect ?? this.isCorrect,
    );
  }
}