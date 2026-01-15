import 'package:green_frontend/features/multiplayer/domain/entities/slide.dart';
import 'package:green_frontend/features/multiplayer/infraestructure/models/option_model.dart';

class SlideModel extends Slide{
  SlideModel({
    required super.id,
    required super.position,
    required super.type,
    required super.timeLimitSeconds,
    required super.questionText,
    super.slideImageUrl,
    super.pointsValue,
    required super.options,
  });

  factory SlideModel.fromJson(Map<String, dynamic> json) {
    return SlideModel(
      id: json['id'] ?? '',
      position: json['position'] ?? 0,
      type: QuestionType.values.firstWhere(
          (e) => e.toString() == 'QuestionType.${json['type']}',
          orElse: () => QuestionType.single),
      timeLimitSeconds: json['timeLimitSeconds'] ?? 0,
      questionText: json['questionText'] ?? '',
      slideImageUrl: json['slideImageUrl'],
      pointsValue: json['pointsValue'],
      options: (json['options'] as List<dynamic>? ?? [])
          .map((optionJson) =>
              OptionModel.fromJson(optionJson as Map<String, dynamic>))
          .toList(),
    );
  }

  Slide toEntity() {
    return Slide(
      id: id,
      position: position,
      type: type,
      timeLimitSeconds: timeLimitSeconds,
      questionText: questionText,
      slideImageUrl: slideImageUrl,
      pointsValue: pointsValue,
      options: options.map((option) => (option as OptionModel).toEntity()).toList(),
    );
  }
  
}