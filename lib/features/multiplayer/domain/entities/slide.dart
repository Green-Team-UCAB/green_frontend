import 'package:green_frontend/features/multiplayer/domain/entities/slide_option.dart';

enum QuestionType { single, multiple, trueFalse}

class Slide { 
  final String id; 
  final int position; 
  final QuestionType type; 
  final int timeLimitSeconds; 
  final String questionText; 
  final String? slideImageUrl; 
  final int? pointsValue; 
  final List<SlideOption> options; 
  
  const Slide({ 
    required this.id, 
    required this.position, 
    required this.type, 
    required this.timeLimitSeconds, 
    required this.questionText, 
    this.slideImageUrl, 
    this.pointsValue, 
    required this.options, 
  }); 
}