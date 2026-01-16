import 'package:green_frontend/features/multiplayer/domain/repositories/multiplayer_socket_repository.dart';
import 'package:green_frontend/features/multiplayer/domain/entities/host_lobby.dart';
import 'package:green_frontend/features/multiplayer/domain/entities/slide.dart';
import 'package:green_frontend/features/multiplayer/domain/entities/host_result.dart';
import 'package:green_frontend/features/multiplayer/domain/entities/player_results.dart';
import 'package:green_frontend/features/multiplayer/domain/entities/summary.dart';
import 'package:green_frontend/core/error/failures.dart';
import 'package:fpdart/fpdart.dart';

/// ---------------------------------------------------------------------------
/// EVENTOS PRINCIPALES DEL CICLO DE JUEGO
/// ---------------------------------------------------------------------------

class ListenRoomJoined {
  final MultiplayerSocketRepository socketRepo;
  ListenRoomJoined(this.socketRepo);

  Stream<Either<Failure, Unit>> call() => socketRepo.onRoomJoined;
}

/// HOST: host_connected_success
class ListenHostConnectedSuccess {
  final MultiplayerSocketRepository socketRepo;
  ListenHostConnectedSuccess(this.socketRepo);

  Stream<Unit> call() => socketRepo.onHostConnectedSuccess;
}

/// PLAYER: player_connected_to_session (evento correcto)
class ListenPlayerConnectedToSession {
  final MultiplayerSocketRepository socketRepo;
  ListenPlayerConnectedToSession(this.socketRepo);

  Stream<Unit> call() => socketRepo.onPlayerConnectedToSession;
}

/// LOBBY UPDATE
class ListenHostLobbyUpdate {
  final MultiplayerSocketRepository socketRepo;
  ListenHostLobbyUpdate(this.socketRepo);

  Stream<HostLobby> call() => socketRepo.onHostLobbyUpdate;
}

/// QUESTION STARTED
class ListenQuestionStarted {
  final MultiplayerSocketRepository socketRepo;
  ListenQuestionStarted(this.socketRepo);

  Stream<Slide> call() => socketRepo.onQuestionStarted;
}

/// HOST RESULTS
class ListenHostResults {
  final MultiplayerSocketRepository socketRepo;
  ListenHostResults(this.socketRepo);

  Stream<HostResults> call() => socketRepo.onHostResults;
}

/// PLAYER RESULTS
class ListenPlayerResults {
  final MultiplayerSocketRepository socketRepo;
  ListenPlayerResults(this.socketRepo);

  Stream<PlayerResults> call() => socketRepo.onPlayerResults;
}

/// GAME END
class ListenGameEnd {
  final MultiplayerSocketRepository socketRepo;
  ListenGameEnd(this.socketRepo);

  Stream<Summary> call() => socketRepo.onGameEnd;
}

/// ---------------------------------------------------------------------------
/// EVENTOS DE CONTROL DE ESTADO
/// ---------------------------------------------------------------------------

class ListenSessionClosed {
  final MultiplayerSocketRepository socketRepo;
  ListenSessionClosed(this.socketRepo);

  Stream<Map<String, dynamic>> call() => socketRepo.onSessionClosed;
}

class ListenPlayerLeft {
  final MultiplayerSocketRepository socketRepo;
  ListenPlayerLeft(this.socketRepo);

  Stream<String> call() => socketRepo.onPlayerLeft;
}

class ListenAnswerUpdate {
  final MultiplayerSocketRepository socketRepo;
  ListenAnswerUpdate(this.socketRepo);

  Stream<int> call() => socketRepo.onAnswerCountUpdate;
}

class ListenSocketError {
  final MultiplayerSocketRepository socketRepo;
  ListenSocketError(this.socketRepo);

  Stream<Failure> call() => socketRepo.onSocketError;
}