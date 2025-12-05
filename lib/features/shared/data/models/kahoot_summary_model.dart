import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/kahoot_summary.dart';

part 'kahoot_summary_model.g.dart';

@JsonSerializable()
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
  });

  factory KahootSummaryModel.fromJson(Map<String, dynamic> json) {
    // Manejo manual para aplanar el objeto 'author' del API
    final authorJson = json['author'] as Map<String, dynamic>?;
    final authorName = authorJson?['name'] as String? ?? 'Unknown';

    return KahootSummaryModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      // El API dice 'coverImageId' pero devuelve una URL string según doc
      coverImageUrl: json['coverImageId'] as String?,
      authorName: authorName,
      status: json['status'] as String? ?? 'draft',
      playCount: json['playCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      visibility: json['visibility'] as String? ?? 'private',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'coverImageId': coverImageUrl,
    'author': {
      'name': authorName,
    }, // Reconstruimos estructura API si fuera necesario enviar
    'status': status,
    'playCount': playCount,
    'createdAt': createdAt.toIso8601String(),
    'visibility': visibility,
  };
}
