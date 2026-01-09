class KahootSummary {
  final String id;
  final String title;
  final String? description;
  final String? coverImageId;
  final String? status;
  final int playCount;
  final bool isFavorite;
  final String? gameId;
  final String? gameType;
  final String? authorName;

  const KahootSummary({
    required this.id,
    required this.title,
    this.description,
    this.coverImageId,
    this.status,
    this.playCount = 0,
    this.isFavorite = false,
    this.gameId,
    this.gameType,
    this.authorName,
  });

  KahootSummary copyWith({
    String? id,
    String? title,
    String? description,
    String? coverImageId,
    String? status,
    int? playCount,
    bool? isFavorite,
    String? gameId,
    String? gameType,
    String? authorName,
  }) {
    return KahootSummary(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      coverImageId: coverImageId ?? this.coverImageId,
      status: status ?? this.status,
      playCount: playCount ?? this.playCount,
      isFavorite: isFavorite ?? this.isFavorite,
      gameId: gameId ?? this.gameId,
      gameType: gameType ?? this.gameType,
      authorName: authorName ?? this.authorName,
    );
  }
}
