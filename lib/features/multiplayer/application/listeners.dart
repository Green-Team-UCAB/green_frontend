import 'package:green_frontend/features/multiplayer/domain/repositories/multiplayer_socket_repository.dart';
import 'package:green_frontend/features/multiplayer/domain/entities/host_lobby.dart';
import 'package:green_frontend/features/multiplayer/domain/entities/slide.dart';
import 'package:green_frontend/features/multiplayer/domain/entities/host_result.dart';
import 'package:green_frontend/features/multiplayer/domain/entities/player_results.dart';
import 'package:green_frontend/features/multiplayer/domain/entities/summary.dart';

/// --- Eventos principales del ciclo de juego ---

class ListenHostLobbyUpdate {
  final MultiplayerSocketRepository socketRepo;
  ListenHostLobbyUpdate(this.socketRepo);

  Stream<HostLobby> call() => socketRepo.onHostLobbyUpdate();
}

class ListenQuestionStarted {
  final MultiplayerSocketRepository socketRepo;
  ListenQuestionStarted(this.socketRepo);

  Stream<Slide> call() => socketRepo.onQuestionStarted();
}

class ListenHostResults {
  final MultiplayerSocketRepository socketRepo;
  ListenHostResults(this.socketRepo);

  Stream<HostResults> call() => socketRepo.onHostResults();
}

class ListenPlayerResults {
  final MultiplayerSocketRepository socketRepo;
  ListenPlayerResults(this.socketRepo);

  Stream<PlayerResults> call() => socketRepo.onPlayerResults();
}

class ListenGameEnd {
  final MultiplayerSocketRepository socketRepo;
  ListenGameEnd(this.socketRepo);

  Stream<Summary> call() => socketRepo.onGameEnd();
}

class ListenSessionClosed {
  final MultiplayerSocketRepository socketRepo;
  ListenSessionClosed(this.socketRepo);

  Stream<Map<String, String>> call() => socketRepo.onSessionClosed();
}

/// --- Eventos de fiabilidad y métricas ---

class ListenHostAnswerUpdate {
  final MultiplayerSocketRepository socketRepo;
  ListenHostAnswerUpdate(this.socketRepo);

  Stream<int> call() => socketRepo.onHostAnswerUpdate();
}

class ListenPlayerLeftSession {
  final MultiplayerSocketRepository socketRepo;
  ListenPlayerLeftSession(this.socketRepo);

  Stream<String> call() => socketRepo.onPlayerLeftSession();
}

class ListenHostLeftSession {
  final MultiplayerSocketRepository socketRepo;
  ListenHostLeftSession(this.socketRepo);

  Stream<String> call() => socketRepo.onHostLeftSession();
}

class ListenHostReturnedToSession {
  final MultiplayerSocketRepository socketRepo;
  ListenHostReturnedToSession(this.socketRepo);

  Stream<String> call() => socketRepo.onHostReturnedToSession();
}

/// --- Eventos de error ---

class ListenGameError {
  final MultiplayerSocketRepository socketRepo;
  ListenGameError(this.socketRepo);

  Stream<String> call() => socketRepo.onGameError();
}

class ListenConnectionError {
  final MultiplayerSocketRepository socketRepo;
  ListenConnectionError(this.socketRepo);

  Stream<String> call() => socketRepo.onConnectionError();
}

class ListenSyncError {
  final MultiplayerSocketRepository socketRepo;
  ListenSyncError(this.socketRepo);

  Stream<String> call() => socketRepo.onSyncError();
}
