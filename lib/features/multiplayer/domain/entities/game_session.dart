import 'package:green_frontend/features/multiplayer/domain/value_objects/session_pin.dart';
import 'package:green_frontend/features/multiplayer/domain/value_objects/qr_token.dart';

class GameSession { 
  final SessionPin sessionPin; 
  final QrToken? qrToken; 
  final String? quizTitle; 
  final String? themeUrl; 
  final String? coverImageUrl; 
  final String? themeName;
  
  GameSession({ 
    required this.sessionPin, 
    this.qrToken, 
    this.quizTitle, 
    this.themeUrl, 
    this.coverImageUrl, 
    this.themeName,
  }); 
}
  
