import '../../domain/entities/kahoot_summary.dart';

class KahootSummaryModel extends KahootSummary {
  const KahootSummaryModel({
    required super.id,
    required super.title,
    required super.description,
    super.coverImageUrl,
    required super.authorName,
    required super.status,
    required super.playCount,
    required super.createdAt,
    required super.visibility,
    super.gameId,
    super.gameType,
  });

  factory KahootSummaryModel.fromJson(Map<String, dynamic> json) {
    // Manejo seguro del autor
    String parsedAuthor = 'Desconocido';
    if (json['author'] != null && json['author'] is Map) {
      parsedAuthor = json['author']['name'] ?? 'Desconocido';
    } else if (json['authorName'] != null) {
      parsedAuthor = json['authorName'];
    }

    // Manejo seguro del status
    final parsedStatus =
        json['Status'] as String? ?? json['status'] as String? ?? 'draft';

    return KahootSummaryModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Sin título',
      description: json['description'] as String? ?? '',
      coverImageUrl: json['coverImageId'] as String?,
      authorName: parsedAuthor,
      status: parsedStatus,
      playCount: (json['playCount'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      visibility: json['visibility'] as String? ?? 'private',
      gameId: json['gameId'] as String?,
      gameType: json['gameType'] as String?,
    );
  }
}
