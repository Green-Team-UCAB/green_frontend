// lib/features/multiplayer/infraestructure/repositories/multiplayer_socket_repository_impl.dart

import 'dart:async';
import 'package:fpdart/fpdart.dart';
import 'package:green_frontend/core/error/failures.dart';
import 'package:green_frontend/features/multiplayer/domain/repositories/multiplayer_socket_repository.dart';
import 'package:green_frontend/features/multiplayer/infraestructure/datasources/multiplayer_socket_datasource.dart';
import 'package:green_frontend/features/multiplayer/infraestructure/models/host_lobby.dart';
import 'package:green_frontend/features/multiplayer/infraestructure/models/slide_model.dart';
import 'package:green_frontend/features/multiplayer/domain/value_objects/session_pin.dart';
import 'package:green_frontend/features/multiplayer/domain/value_objects/nickname.dart';
import 'package:green_frontend/features/multiplayer/domain/value_objects/answer_id.dart'; // Para submitAnswer
import 'package:green_frontend/features/multiplayer/domain/value_objects/time_elapsed_ms.dart';
import 'package:green_frontend/features/multiplayer/domain/entities/host_lobby.dart';
import 'package:green_frontend/features/multiplayer/domain/entities/slide.dart';
import 'package:green_frontend/features/multiplayer/domain/entities/summary.dart';
import 'package:green_frontend/features/multiplayer/domain/entities/host_result.dart';
import 'package:green_frontend/features/multiplayer/domain/entities/player_results.dart';
import 'package:green_frontend/features/multiplayer/infraestructure/models/host_result.dart';
import 'package:green_frontend/features/multiplayer/infraestructure/models/player_results_model.dart';
import 'package:green_frontend/features/multiplayer/infraestructure/models/summary_model.dart';
import 'package:green_frontend/features/multiplayer/domain/value_objects/client_role.dart';




class MultiplayerSocketRepositoryImpl implements MultiplayerSocketRepository {
  final MultiplayerSocketDataSource dataSource;

  MultiplayerSocketRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, Unit>> connect({
    required ClientRole role,
    required SessionPin pin,
    required String jwt,
  }) async {
    try {
      // La URL se puede inyectar o venir de una config global
      const String socketUrl = 'https://quizzy-backend-0wh2.onrender.com';
      await dataSource.connect(url: socketUrl, jwt: jwt);
      return right(unit);
    } catch (e) {
      return left(ServerFailure('Error al conectar con el servidor de juegos'));
    }
  }

  // --- EMISORES (Acciones del usuario) ---

  @override
  void emitPlayerJoin(Nickname nickname) {
    dataSource.emit('join_room', {'nickname': nickname.value});
  }

  @override
  void emitClientReady() {
    dataSource.emit('client_ready', {});
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

  @override
  void emitHostStartGame() {
    dataSource.emit('start_game', {});
  }

  // --- ESCUCHAS (Transformación de Datos) ---

  @override
  Stream<Either<Failure, Unit>> get onRoomJoined => dataSource.onRoomJoined.map(
    (data) => right(unit)
  );

  @override
  Stream<HostLobby> get onHostLobbyUpdate => dataSource.onPlayersUpdate.map(
    (data) => HostLobbyModel.fromJson(data).toEntity()
  );

  @override
  Stream<Slide> get onQuestionStarted => dataSource.onQuestionStarted.map(
    (data) => SlideModel.fromJson(data).toEntity()
  );

  @override
  Stream<HostResults> get onHostResults => dataSource.onHostResults.map(
    (data) => HostResultModel.fromJson(data).toEntity()
  );

  @override
  Stream<PlayerResults> get onPlayerResults => dataSource.onPlayerResults.map(
    (data) => PlayerResultsModel.fromJson(data).toEntity()
  );

  @override
  Stream<Summary> get onGameEnd => dataSource.onGameEnd.map(
    (data) => SummaryModel.fromJson(data).toEntity()
  );

  @override
  Stream<Failure> get onSocketError => dataSource.onError.map(
    (error) => ServerFailure(error.toString())
  );

  @override
  Stream<Map<String, dynamic>> get onSessionClosed => dataSource.onSessionClosed;

  @override
  Stream<String> get onPlayerLeft => dataSource.onPlayerLeft.map(
    (data) => data['nickname'] as String // Extraemos el nombre del que se fue
  );

  @override
  Stream<int> get onAnswerCountUpdate => dataSource.onAnswerCountUpdate.map(
    (data) => data['count'] as int // Según Pág 61, devuelve el conteo
  );

  @override
  Future<void> disconnect() async {
    dataSource.disconnect();
  }
  
}