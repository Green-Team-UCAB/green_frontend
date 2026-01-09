import '../../domain/entities/kahoot_summary.dart';

class KahootSummaryModel extends KahootSummary {
  const KahootSummaryModel({
    required super.id,
    required super.title,
    super.description,
    super.coverImageId,
    super.status,
    super.playCount,
    super.isFavorite,
    super.gameId,
    super.gameType,
  });

  factory KahootSummaryModel.fromJson(Map<String, dynamic> json) {
    return KahootSummaryModel(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Sin título',
      description: json['description'],
      coverImageId: json['coverImageId'],
      status: json['Status'] ?? json['status'],
      playCount: json['playCount'] ?? 0,
      isFavorite: json['isFavorite'] ?? false,
      gameId: json['gameId'],
      gameType: json['gameType'],
    );
  }
}
