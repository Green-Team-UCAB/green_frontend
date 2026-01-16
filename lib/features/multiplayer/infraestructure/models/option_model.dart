// lib/features/multiplayer/infraestructure/models/option_model.dart

import 'package:green_frontend/features/multiplayer/domain/entities/slide_option.dart';

class OptionModel extends SlideOption {
  const OptionModel({
    required super.index,
    required super.text,
    super.mediaUrl,
    super.isCorrect = false, 
  });

  factory OptionModel.fromJson(Map<String, dynamic> json) {
    return OptionModel(
      index: json['index'] ?? 0,
      text: json['text'] ?? '',


      mediaUrl: json['mediaUrl'] as String?,


      isCorrect: (json['isCorrect'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'text': text,
      'mediaUrl': mediaUrl,
      'isCorrect': isCorrect,
    };
  }

  SlideOption toEntity() {
    return SlideOption(
      index: index,
      text: text,
      mediaUrl: mediaUrl,
      isCorrect: isCorrect,
    );
  }
}
