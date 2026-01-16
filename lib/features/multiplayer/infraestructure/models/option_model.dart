// lib/features/multiplayer/infraestructure/models/option_model.dart

import 'package:green_frontend/features/multiplayer/domain/entities/slide_option.dart';

class OptionModel extends SlideOption {
  const OptionModel({
    required super.index,
    required super.text,
    super.mediaUrl,
    super.isCorrect = false, // Valor por defecto en el constructor
  });

  factory OptionModel.fromJson(Map<String, dynamic> json) {
    return OptionModel(
      index: json['index'] ?? 0,
      text: json['text'] ?? '',

      // ✅ CORRECCIÓN 1: mediaUrl es String opcional
      mediaUrl: json['mediaUrl'] as String?,

      // ✅ CORRECCIÓN 2: isCorrect maneja nulos (Para el Player) y booleanos (Para el Host)
      // Si viene null (Player), se convierte en false.
      // Si viene true/false (Host), se usa ese valor.
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
