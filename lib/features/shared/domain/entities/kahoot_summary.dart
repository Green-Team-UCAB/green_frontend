import 'package:equatable/equatable.dart';

class KahootSummary extends Equatable {
  final String id;
  final String title;
  final String description;
  final String? coverImageUrl; // Mapeado desde 'coverImageId'
  final String authorName; // Mapeado desde 'author.name'
  final String status; // 'draft' | 'published'
  final int playCount;
  final DateTime createdAt;
  final String visibility; // 'public' | 'private'

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
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    coverImageUrl,
    authorName,
    status,
    playCount,
    createdAt,
    visibility,
  ];
}
