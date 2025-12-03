import 'package:kahoot_project/features/kahoot/domain/entities/kahoot.dart';
import 'package:kahoot_project/features/kahoot/infrastructure/repositories/mappers/question_mapper.dart';

class KahootMapper {
  // Convierte un Map (JSON) a una entidad Kahoot
  static Kahoot fromMap(Map<String, dynamic> map) {
    return Kahoot(
      id: map['id'],
      title: map['title'] ?? '',
      description: map['description'],
      coverImageId: map['coverImageId'],
      visibility: map['visibility'] ?? 'private',
      themeId: map['themeId'] ?? '',
      authorId: map['authorId'],
      status: map['status'] ?? 'draft',
      questions: List<Map<String, dynamic>>.from(map['questions'] ?? [])
          .map(QuestionMapper.fromMap)
          .toList(),
      category: map['category'],
      playCount: map['playCount'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : null,
    );
  }

  // Convierte una entidad Kahoot a un Map (JSON)
  static Map<String, dynamic> toMap(Kahoot kahoot) {
    return {
      if (kahoot.id != null) 'id': kahoot.id,
      'title': kahoot.title,
      if (kahoot.description != null) 'description': kahoot.description,
      if (kahoot.coverImageId != null) 'coverImageId': kahoot.coverImageId,
      'visibility': kahoot.visibility,
      'themeId': kahoot.themeId,
      if (kahoot.authorId != null) 'authorId': kahoot.authorId,
      'status': kahoot.status,
      'questions': kahoot.questions.map(QuestionMapper.toMap).toList(),
      if (kahoot.category != null) 'category': kahoot.category,
      if (kahoot.playCount != null) 'playCount': kahoot.playCount,
      if (kahoot.createdAt != null)
        'createdAt': kahoot.createdAt!.toIso8601String(),
    };
  }
}