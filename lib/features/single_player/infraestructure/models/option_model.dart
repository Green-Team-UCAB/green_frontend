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

  return OptionModel(
      index: int.tryParse(json['index'].toString()) ?? 0, 
      text: json['text'] as String?,
      mediaId: (json['mediaId'] ?? json['mediaID']) as String?,
    );
  
}
  
  Option toEntity() {
    return Option(
      index: index,
      text: text,
      mediaID: mediaId,
    );
  }
  }