import 'package:green_frontend/features/kahoot/domain/entities/question.dart';


class Kahoot {
  String? id;
  String title;
  String? description;
  String? coverImageId;
  String visibility;
  String themeId;
  String? authorId;
  String status;
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

  Kahoot copyWith({
    String? id,
    String? title,
    String? description,
    String? coverImageId,
    String? visibility,
    String? themeId,
    String? authorId,
    String? status,
    List<Question>? questions,
    String? category,
    int? playCount,
    DateTime? createdAt,
  }) {
    return Kahoot(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      coverImageId: coverImageId ?? this.coverImageId,
      visibility: visibility ?? this.visibility,
      themeId: themeId ?? this.themeId,
      authorId: authorId ?? this.authorId,
      status: status ?? this.status,
      questions: questions ?? this.questions,
      category: category ?? this.category,
      playCount: playCount ?? this.playCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
