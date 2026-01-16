// lib/features/multiplayer/infraestructure/repositories/multiplayer_socket_repository_impl.dart

import 'dart:async';
import 'package:fpdart/fpdart.dart';
import 'package:green_frontend/core/error/failures.dart';
import 'package:green_frontend/features/multiplayer/domain/repositories/multiplayer_socket_repository.dart';
import 'package:green_frontend/features/multiplayer/infraestructure/datasources/multiplayer_socket_datasource.dart';

// Models
import 'package:green_frontend/features/multiplayer/infraestructure/models/host_lobby.dart';
import 'package:green_frontend/features/multiplayer/infraestructure/models/slide_model.dart';
import 'package:green_frontend/features/multiplayer/infraestructure/models/host_result.dart';
import 'package:green_frontend/features/multiplayer/infraestructure/models/player_results_model.dart';
import 'package:green_frontend/features/multiplayer/infraestructure/models/summary_model.dart';

// Domain
import 'package:green_frontend/features/multiplayer/domain/value_objects/session_pin.dart';
import 'package:green_frontend/features/multiplayer/domain/value_objects/nickname.dart';
import 'package:green_frontend/features/multiplayer/domain/value_objects/answer_id.dart';
import 'package:green_frontend/features/multiplayer/domain/value_objects/time_elapsed_ms.dart';
import 'package:green_frontend/features/multiplayer/domain/value_objects/client_role.dart';

import 'package:green_frontend/features/multiplayer/domain/entities/host_lobby.dart';
import 'package:green_frontend/features/multiplayer/domain/entities/slide.dart';
import 'package:green_frontend/features/multiplayer/domain/entities/summary.dart';
import 'package:green_frontend/features/multiplayer/domain/entities/host_result.dart';
import 'package:green_frontend/features/multiplayer/domain/entities/player_results.dart';

class MultiplayerSocketRepositoryImpl implements MultiplayerSocketRepository {
  final MultiplayerSocketDataSource dataSource;
  final String baseUrl;

  MultiplayerSocketRepositoryImpl({
    required this.dataSource,
    required this.baseUrl,
  });

  // ---------------------------------------------------------------------------
  // CONEXIÓN
  // ---------------------------------------------------------------------------

  @override
  Future<Either<Failure, Unit>> connect({
    required ClientRole role,
    required SessionPin pin,
    required String jwt,
  }) async {
    print("DEBUG: Conectando con URL: $baseUrl");

    try {
      final roleString = role.toString().split('.').last.toUpperCase();

      await dataSource.connect(
        url: baseUrl,
        jwt: jwt,
        role: roleString,
        pin: pin.value.toString(),
      );

      return right(unit);
    } catch (e) {
      return left(ServerFailure('Error al conectar con el servidor de juegos'));
    }
  }

  @override
  Future<void> disconnect() async {
    dataSource.disconnect();
  }

  // ---------------------------------------------------------------------------
  // EMISORES (CLIENT → SERVER)
  // ---------------------------------------------------------------------------

  @override
  void emitPlayerJoin(Nickname nickname) {
    dataSource.emit('player_join', {'nickname': nickname.value});
  }

  @override
  void emitClientReady(ClientRole role, SessionPin pin) {
    dataSource.emit('client_ready', {
      'role': role == ClientRole.host ? 'host' : 'player',
      'pin': pin.value.toString(),
    });
  }

  @override
  void emitHostStartGame() {
    dataSource.emit('host_start_game', {});
  }

  @override
  void emitHostNextPhase() {
    dataSource.emit('next_phase', {});
  }

  @override
  void emitPlayerSubmitAnswer({
    required String questionId,
    required AnswerIds answerIds,
    required TimeElapsedMs timeElapsedMs,
  }) {
    dataSource.emit('submit_answer', {
      'questionId': questionId,
      'answerIds': answerIds.value,
      'timeElapsed': timeElapsedMs.value,
    });
  }

  // ---------------------------------------------------------------------------
  // LISTENERS (SERVER → CLIENT)
  // ---------------------------------------------------------------------------

  @override
  Stream<Unit> get onHostConnectedSuccess =>
      dataSource.onHostConnectedSuccess.map((_) => unit);

  /// 🔥 CORRECTO: este es el evento que indica que el player ya está en la sesión
  @override
  Stream<Unit> get onPlayerConnectedToSession =>
      dataSource.onPlayerConnectedToSession.map((_) => unit);

  @override
  Stream<Either<Failure, Unit>> get onRoomJoined =>
      dataSource.onRoomJoined.map((_) => right(unit));

  @override
  Stream<HostLobby> get onHostLobbyUpdate =>
      dataSource.onPlayersUpdate.map(
        (data) => HostLobbyModel.fromJson(data).toEntity(),
      );

  @override
Stream<Slide> get onQuestionStarted =>
    dataSource.onQuestionStarted.map(
      (data) => SlideModel.fromJson(data).toEntity(),
    );

  @override
  Stream<HostResults> get onHostResults =>
      dataSource.onHostResults
          .where((data) => data.isNotEmpty)
          .map((data) => HostResultModel.fromJson(data).toEntity());

  @override
  Stream<PlayerResults> get onPlayerResults =>
      dataSource.onPlayerResults.map(
        (data) => PlayerResultsModel.fromJson(data).toEntity(),
      );

  @override
  Stream<Summary> get onGameEnd =>
      dataSource.onGameEnd.map(
        (data) => SummaryModel.fromJson(data).toEntity(),
      );

  @override
  Stream<Failure> get onSocketError =>
      dataSource.onError.map((error) => ServerFailure(error.toString()));

  @override
  Stream<Map<String, dynamic>> get onSessionClosed =>
      dataSource.onSessionClosed;

  @override
  Stream<String> get onPlayerLeft =>
      dataSource.onPlayerLeft.map((data) => data['nickname'] as String);

  @override
  Stream<int> get onAnswerCountUpdate =>
      dataSource.onAnswerCountUpdate.map((data) => data['count'] as int);
}