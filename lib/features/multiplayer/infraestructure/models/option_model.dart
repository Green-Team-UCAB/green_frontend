import 'package:green_frontend/features/multiplayer/domain/entities/slide_option.dart';

class OptionModel extends SlideOption {
  OptionModel({
    required super.index,
    required super.text,
    required super.mediaUrl,
  });

  factory OptionModel.fromJson(Map<String, dynamic> json) {
    return OptionModel(
      index: json['index'] ?? 0,
      text: json['text'] ?? '',
      mediaUrl: json['mediaUrl'] ?? false,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'text': text,
      'mediaUrl': mediaUrl,
    };
  }

  SlideOption toEntity() {
    return SlideOption(
      index: index,
      text: text,
      mediaUrl: mediaUrl,
    );
  }
}