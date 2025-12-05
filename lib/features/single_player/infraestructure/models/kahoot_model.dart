import 'package:green_frontend/features/single_player/infraestructure/models/game_state_model.dart';
import 'package:green_frontend/features/single_player/domain/entities/kahoot.dart';

class KahootModel {
  final String id;
  final String title;
  final String? description;
  final String? thumbnailUrl;
  final bool isFavorite;
  final bool isInProgress;
  final bool isCompleted;
  final GameStateModel? gameState;

  KahootModel({
    required this.id,
    required this.title,
    this.description,
    this.thumbnailUrl,
    this.isFavorite = false,
    this.isInProgress = false,
    this.isCompleted = false,
    this.gameState,
  });

  factory KahootModel.fromJson(Map<String, dynamic> json) => KahootModel(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String?,
    thumbnailUrl: json['thumbnailUrl'] as String?,
    isFavorite: json['isFavorite'] == true,
    isInProgress: json['isInProgress'] == true,
    isCompleted: json['isCompleted'] == true,
    gameState: json['gameState'] != null ? GameStateModel.fromJson(Map<String,dynamic>.from(json['gameState'])) : null,
  );

  Kahoot toEntity() {
    return Kahoot(
      id: id,
      title: title,
      description: description,
      thumbnailUrl: thumbnailUrl,
      isFavorite: isFavorite,
      isInProgress: isInProgress,
      isCompleted: isCompleted,
      gameState: gameState?.toEntity(),
    );
  }
}