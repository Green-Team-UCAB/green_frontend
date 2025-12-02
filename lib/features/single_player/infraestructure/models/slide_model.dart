import 'package:green_frontend/features/single_player/infraestructure/models/option_model.dart';
import'package:green_frontend/features/single_player/domain/entities/slide.dart';

class SlideModel {
  final String slideId;
  final String questionText;
  final QuestionType questionType;
  final int timeLimitSeconds;
  final String? mediaId;
  final List<OptionModel> options;

  SlideModel({
    required this.slideId,
    required this.questionText,
    required this.questionType,
    required this.timeLimitSeconds,
    this.mediaId,
    required this.options,
  });

  factory SlideModel.fromJson(Map<String, dynamic> json) {
    return SlideModel(
      slideId: json['slideId'],
      questionText: json['questionText'],
      questionType: json['questionType'],
      timeLimitSeconds: json['timeLimitSeconds'],
      mediaId: json['mediaId'],
      options: (json['options'] as List)
          .map((optionJson) => OptionModel.fromJson(optionJson))
          .toList(),
    );
  }

  Slide toEntity() {
    return Slide(
      slideId: slideId,
      questionText: questionText,
      questionType: questionType,
      timeLimitSeconds: timeLimitSeconds,
      mediaId: mediaId,
      options: options.map((optionModel) => optionModel.toEntity()).toList(),
    );
  }
}
