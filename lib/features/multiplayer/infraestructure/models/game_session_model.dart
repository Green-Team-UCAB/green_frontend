import '../../domain/entities/game_session.dart';
import '../../domain/value_objects/session_pin.dart';
import '../../domain/value_objects/qr_token.dart';

class GameSessionModel extends GameSession {
  GameSessionModel({
    required super.sessionPin,
    super.qrToken,
    super.quizTitle,
    super.themeUrl,
    super.coverImageUrl,
    super.themeName,
  });

  factory GameSessionModel.fromJson(Map<String, dynamic> json) {
    return GameSessionModel(
      sessionPin: SessionPin(json['sessionPin']),
      qrToken: json['qrToken'] != null ? QrToken(json['qrToken']) : null,
      quizTitle: json['quizTitle'],
      coverImageUrl: json['coverImageUrl'],
      // Accediendo al objeto anidado del tema según la API
      themeUrl: json['theme']?['url'],
      themeName: json['theme']?['name'],
    );
  }
}