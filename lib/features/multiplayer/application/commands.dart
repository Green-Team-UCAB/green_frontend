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

class ConnectToGame {
  final MultiplayerSocketRepository repository;

  ConnectToGame(this.repository);

  Future<Either<Failure, Unit>> call({
    required ClientRole role,
    required SessionPin pin,
    required String jwt,
  }) async {
    return await repository.connect(
      role: role,
      pin: pin,
      jwt: jwt,
    );
  }
}

class JoinRoom {
  final MultiplayerSocketRepository repository;

  JoinRoom(this.repository);

  Future<Either<Failure, Unit>> call(Nickname nickname) async {
    repository.emitPlayerJoin(nickname);
    return right(unit); 
  }
}

class StartGame {
  final MultiplayerSocketRepository socketRepo;
  StartGame(this.socketRepo);

  Future<Either<Failure, Unit>> call() async {

    socketRepo.emitHostStartGame();
    return right(unit);
  }
}

class NextPhase {
  final MultiplayerSocketRepository socketRepo;
  NextPhase(this.socketRepo);

  Future<Either<Failure, Unit>> call() async {
    socketRepo.emitHostNextPhase();
    return right(unit);
  }
}

class SubmitAnswer {
  final MultiplayerSocketRepository repository;

  SubmitAnswer(this.repository);

  Future<Either<Failure, Unit>> call({
    required String questionId,
    required AnswerIds answerIds,
    required TimeElapsedMs timeElapsedMs,
  }) async {
    repository.emitPlayerSubmitAnswer(
      questionId: questionId,
      answerIds: answerIds,
      timeElapsedMs: timeElapsedMs,
    );
    return right(unit);
  }
}

class EndSession {
  final MultiplayerSocketRepository repository;

  EndSession(this.repository);

  Future<Either<Failure, Unit>> call() async {
    await repository.disconnect();
    return right(unit);
  }
}


