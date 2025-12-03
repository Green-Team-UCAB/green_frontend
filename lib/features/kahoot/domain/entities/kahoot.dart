import 'package:kahoot_project/features/kahoot/domain/entities/question.dart';

class Kahoot {
  String? id;
  String title;
  String? description;
  String? coverImageId;
  String visibility; // 'public' or 'private'
  String themeId;
  String? authorId;
  String status; // 'draft' or 'published'
  List<Question> questions;
  String? category;
  int? playCount;
  DateTime? createdAt;

  Kahoot({
    this.id,
    required this.title,
    this.description,
    this.coverImageId,
    required this.visibility,
    required this.themeId,
    this.authorId,
    required this.status,
    required this.questions,
    this.category,
    this.playCount,
    this.createdAt,
  });

  factory Kahoot.empty() => Kahoot(
        title: '',
        visibility: 'private',
        themeId: '',
        status: 'draft',
        questions: [],
      );

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'coverImageId': coverImageId,
      'visibility': visibility,
      'themeId': themeId,
      'status': status,
      'questions': questions.map((q) => q.toJson()).toList(),
      'category': category,
    };
  }
}