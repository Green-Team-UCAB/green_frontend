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
      sessionPin: SessionPin(json['sessionPin'].toString()),
      qrToken: json['qrToken'] != null ? QrToken(json['qrToken']) : null,
      quizTitle: json['quizTitle'],
      coverImageUrl: json['coverImageUrl'],
      themeUrl: json['theme']?['url'],
      themeName: json['theme']?['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionPin': sessionPin.value,
      if (qrToken != null) 'qrToken': qrToken!.value,
      if (quizTitle != null) 'quizTitle': quizTitle,
      if (coverImageUrl != null) 'coverImageUrl': coverImageUrl,
      if (themeUrl != null || themeName != null)
        'theme': {
          if (themeUrl != null) 'url': themeUrl,
          if (themeName != null) 'name': themeName,
        },
    };
  }

  GameSession toEntity() {
    return GameSession(
      sessionPin: sessionPin,
      qrToken: qrToken,
      quizTitle: quizTitle,
      themeUrl: themeUrl,
      coverImageUrl: coverImageUrl,
      themeName: themeName,
    );
  }
}