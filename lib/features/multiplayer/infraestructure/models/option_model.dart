import 'package:green_frontend/features/multiplayer/domain/entities/slide_option.dart';


class OptionModel {
  final int index;
  final String? text;
  final String? mediaURL;

  OptionModel({
    required this.index,
    this.text,
    this.mediaURL,
  });

  factory OptionModel.fromJson(Map<String, dynamic> json) {
    return OptionModel(
      index: json['index'],
      text: json['text'],
      mediaURL: json['mediaURL'],
    );
  }

  Option toEntity() {
    return Option(
      index: index,
      text: text ?? '',
      mediaUrl: mediaURL,
    );
  }
}