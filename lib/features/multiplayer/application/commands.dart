import 'package:fpdart/fpdart.dart';
import 'package:green_frontend/core/error/failures.dart';
import 'package:green_frontend/features/multiplayer/domain/repositories/multiplayer_session_repository.dart';
import 'package:green_frontend/features/multiplayer/domain/repositories/multiplayer_socket_repository.dart';
import 'package:green_frontend/features/multiplayer/domain/entities/game_session.dart';
import 'package:green_frontend/features/multiplayer/domain/value_objects/qr_token.dart';
import 'package:green_frontend/features/multiplayer/domain/value_objects/session_pin.dart';
import 'package:green_frontend/features/multiplayer/domain/value_objects/nickname.dart';
import 'package:green_frontend/features/multiplayer/domain/value_objects/answer_id.dart';
import 'package:green_frontend/features/multiplayer/domain/value_objects/time_elapsed_ms.dart';


/// --- Preparación y conexión ---

class CreateMultiplayerSession {
  final MultiplayerSessionRepository repository;
  CreateMultiplayerSession(this.repository);

  Future<Either<Failure, GameSession>> call({
    required String kahootId,
    required String jwt,
  }) {
    return repository.createSession(kahootId: kahootId, jwt: jwt);
  }
}

class ResolvePinFromQr {
  final MultiplayerSessionRepository repository;
  ResolvePinFromQr(this.repository);

  Future<Either<Failure, SessionPin>> call({required QrToken qrToken}) {
    return repository.getPinByQrToken(qrToken: qrToken);
  }
}

class ConnectAsHost {
  final MultiplayerSocketRepository socketRepo;
  ConnectAsHost(this.socketRepo);

  Future<Either<Failure, Unit>> call({
    required Uri wsBaseUrl,
    required SessionPin pin,
    required String jwt,
  }) async {
    final result = await socketRepo.connectToGameSession(
      wsBaseUrl: wsBaseUrl,
      role: ClientRole.host,
      pin: pin,
      jwt: jwt,
    );
    return result.map((_) {
      socketRepo.emitClientReady();
      return unit;
    });
  }
}

class ConnectAsPlayer {
  final MultiplayerSocketRepository socketRepo;
  ConnectAsPlayer(this.socketRepo);

  Future<Either<Failure, Unit>> call({
    required Uri wsBaseUrl,
    required SessionPin pin,
    required String jwt,
    required Nickname nickname,
  }) async {
    final result = await socketRepo.connectToGameSession(
      wsBaseUrl: wsBaseUrl,
      role: ClientRole.player,
      pin: pin,
      jwt: jwt,
    );
    return result.map((_) {
      socketRepo.emitClientReady();
      socketRepo.emitPlayerJoin(nickname);
      return unit;
    });
  }
}

/// --- Flujo de juego (Host) ---

class StartGame {
  final MultiplayerSocketRepository socketRepo;
  StartGame(this.socketRepo);

  Either<Failure, Unit> call() => socketRepo.emitHostStartGame();
}

class NextPhase {
  final MultiplayerSocketRepository socketRepo;
  NextPhase(this.socketRepo);

  Either<Failure, Unit> call() => socketRepo.emitHostNextPhase();
}

class EndSession {
  final MultiplayerSocketRepository socketRepo;
  EndSession(this.socketRepo);

  Either<Failure, Unit> call() => socketRepo.emitHostEndSession();
}

/// --- Flujo de juego (Player) ---

class SubmitPlayerAnswer {
  final MultiplayerSocketRepository socketRepo;
  SubmitPlayerAnswer(this.socketRepo);

  Either<Failure, Unit> call({
    required String questionId,
    required AnswerIds answerIds,
    required TimeElapsedMs elapsedMs,
  }) {
    return socketRepo.emitPlayerSubmitAnswer(
      questionId: questionId,
      answerIds: answerIds,
      timeElapsedMs: elapsedMs,
    );
  }
}
