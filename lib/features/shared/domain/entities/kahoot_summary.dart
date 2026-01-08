import 'package:equatable/equatable.dart';

class KahootSummary extends Equatable {
  final String id;
  final String title;
  final String description;
  final String? coverImageUrl;
  final String authorName;
  final String status;
  final int playCount;
  final DateTime createdAt;
  final String visibility;

  // Campos nuevos para la biblioteca
  final String? gameId;
  final String? gameType;

  const KahootSummary({
    required this.id,
    required this.title,
    required this.description,
    this.coverImageUrl,
    required this.authorName,
    required this.status,
    required this.playCount,
    required this.createdAt,
    required this.visibility,
    this.gameId,
    this.gameType,
  });

  @override
  List<Object?> get props => [id, title, status, gameId, gameType];
}
