import 'package:green_frontend/features/single_player/domain/entities/option.dart';

class OptionModel {
  final int index;
  final String? text;
  final String? mediaId;

  OptionModel({
    required this.index,
    this.text,
    this.mediaId,
  });

  factory OptionModel.fromJson(Map<String, dynamic> json) {
  final rawIndex = json['index'];
  final indexValue = rawIndex is int ? rawIndex : int.tryParse(rawIndex?.toString() ?? '') ?? 0;

  return OptionModel(
    index: indexValue,
    text: json['text'] as String?,
    mediaId: json['mediaId'] as String?,
  );
}
  
  Option toEntity() {
    return Option(
      index: index,
      text: text,
      mediaId: mediaId,
    );
  }
  }