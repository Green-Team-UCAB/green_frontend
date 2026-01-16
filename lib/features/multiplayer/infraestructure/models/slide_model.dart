import 'package:green_frontend/features/multiplayer/domain/entities/slide.dart';
import 'package:green_frontend/features/multiplayer/infraestructure/models/option_model.dart';

// infrastructure/models/slide_model.dart


class SlideModel {
  final String id;
  final int position;
  final String slideType;
  final int timeLimitSeconds;
  final String questionText;
  final String? slideImageURL;
  final int pointsValue;
  final List<OptionModel> options;

  SlideModel({
    required this.id,
    required this.position,
    required this.slideType,
    required this.timeLimitSeconds,
    required this.questionText,
    required this.slideImageURL,
    required this.pointsValue,
    required this.options,
  });

  factory SlideModel.fromJson(Map<String, dynamic> json) {
    return SlideModel(
      id: json['id'],
      position: json['position'],
      slideType: json['slideType'],
      timeLimitSeconds: json['timeLimitSeconds'],
      questionText: json['questionText'],
      slideImageURL: json['slideImageURL'],
      pointsValue: json['pointsValue'],
      options: (json['options'] as List)
          .map((o) => OptionModel.fromJson(o))
          .toList(),
    );
  }

  Slide toEntity() {
    return Slide(
      id: id,
      position: position,
      slideType: slideType,
      timeLimitSeconds: timeLimitSeconds,
      questionText: questionText,
      slideImageUrl: slideImageURL,
      pointsValue: pointsValue,
      options: options.map((o) => o.toEntity()).toList(),
    );
  }
}