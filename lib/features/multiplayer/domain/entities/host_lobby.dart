import 'package:green_frontend/features/multiplayer/domain/entities/player.dart';

class HostLobby { 
  final List<Player> players; 
  final int numberOfPlayers; 
  
  const HostLobby({
    required this.players, 
    required this.numberOfPlayers
  }); 
}