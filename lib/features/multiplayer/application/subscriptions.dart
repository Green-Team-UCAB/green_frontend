import 'package:green_frontend/features/multiplayer/domain/repositories/multiplayer_socket_repository.dart';
import 'package:green_frontend/features/multiplayer/domain/entities/host_lobby.dart';
import 'package:green_frontend/features/multiplayer/domain/entities/slide.dart';
import 'package:green_frontend/features/multiplayer/domain/entities/host_result.dart';
import 'package:green_frontend/features/multiplayer/domain/entities/player_results.dart';
import 'package:green_frontend/features/multiplayer/domain/entities/summary.dart';
import 'package:green_frontend/core/error/failures.dart';
import 'package:fpdart/fpdart.dart';

/// --- Eventos principales del ciclo de juego ---

class ListenRoomJoined {
  final MultiplayerSocketRepository socketRepo;
  ListenRoomJoined(this.socketRepo);

  Stream<Either<Failure, Unit>> call() => socketRepo.onRoomJoined;
}

// Esta clase debería escuchar específicamente 'host_connected_success'
class ListenHostConnectedSuccess {
  final MultiplayerSocketRepository socketRepo;
  ListenHostConnectedSuccess(this.socketRepo);

  Stream<Unit> call() => socketRepo.onHostConnectedSuccess;
}

// Y esta 'player_connected_to_session'
class ListenPlayerConnectedSuccess {
  final MultiplayerSocketRepository socketRepo;
  ListenPlayerConnectedSuccess(this.socketRepo);

  Stream<Unit> call() => socketRepo.onPlayerConnectedSuccess;
}

class ListenHostLobbyUpdate {
  final MultiplayerSocketRepository socketRepo;
  ListenHostLobbyUpdate(this.socketRepo);

  Stream<HostLobby> call() => socketRepo.onHostLobbyUpdate;
}

class ListenQuestionStarted {
  final MultiplayerSocketRepository socketRepo;
  ListenQuestionStarted(this.socketRepo);

  Stream<Slide> call() => socketRepo.onQuestionStarted;
}

class ListenHostResults {
  final MultiplayerSocketRepository socketRepo;
  ListenHostResults(this.socketRepo);

  Stream<HostResults> call() => socketRepo.onHostResults;
}

class ListenPlayerResults {
  final MultiplayerSocketRepository socketRepo;
  ListenPlayerResults(this.socketRepo);

  Stream<PlayerResults> call() => socketRepo.onPlayerResults;
}

class ListenGameEnd {
  final MultiplayerSocketRepository socketRepo;
  ListenGameEnd(this.socketRepo);

  Stream<Summary> call() => socketRepo.onGameEnd;
}


///---Eventos de control de estado

class ListenSessionClosed {
  final MultiplayerSocketRepository socketRepo;
  ListenSessionClosed(this.socketRepo);
  // Avisa al usuario que la sesión terminó abruptamente
  Stream<Map<String, dynamic>> call() => socketRepo.onSessionClosed;
}

class ListenPlayerLeft {
  final MultiplayerSocketRepository socketRepo;
  ListenPlayerLeft(this.socketRepo);
  // Cuando alguien se va (player_left)
  Stream<String> call() => socketRepo.onPlayerLeft;
}

class ListenAnswerUpdate {
  final MultiplayerSocketRepository socketRepo;
  ListenAnswerUpdate(this.socketRepo);
  // Conteo de respuestas en tiempo real (Pág 61 - answer_update)
  Stream<int> call() => socketRepo.onAnswerCountUpdate;
}

class ListenSocketError {
  final MultiplayerSocketRepository socketRepo;
  ListenSocketError(this.socketRepo);

  Stream<Failure> call() => socketRepo.onSocketError;
}













