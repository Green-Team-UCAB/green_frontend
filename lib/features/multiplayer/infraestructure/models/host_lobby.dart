import 'package:green_frontend/features/multiplayer/domain/entities/host_lobby.dart';
import 'package:green_frontend/features/multiplayer/infraestructure/models/player_model.dart';

class HostLobbyModel extends HostLobby {
  const HostLobbyModel({
    required super.players,
    required super.numberOfPlayers,
  });

  factory HostLobbyModel.fromJson(Map<String, dynamic> json) {
    return HostLobbyModel(
        players: (json['players'] as List<dynamic>)
          .map((player) => PlayerModel.fromJson(player as Map<String, dynamic>))
          .toList(),
      numberOfPlayers: json['numberOfPlayers'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'players': players
          .map((player) => (player as PlayerModel).toJson())
          .toList(),
      'numberOfPlayers': numberOfPlayers,
    };
  }
}