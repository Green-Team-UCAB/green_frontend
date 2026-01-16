import 'package:green_frontend/features/multiplayer/domain/value_objects/session_pin.dart';
import 'package:green_frontend/features/multiplayer/domain/value_objects/nickname.dart';
import 'package:green_frontend/features/multiplayer/domain/value_objects/answer_id.dart';
import 'package:green_frontend/features/multiplayer/domain/value_objects/time_elapsed_ms.dart';
import 'package:green_frontend/features/multiplayer/domain/entities/host_lobby.dart';
import 'package:green_frontend/features/multiplayer/domain/entities/slide.dart';
import 'package:green_frontend/features/multiplayer/domain/entities/host_result.dart';
import 'package:green_frontend/features/multiplayer/domain/entities/player_results.dart';
import 'package:green_frontend/features/multiplayer/domain/entities/summary.dart';
import 'package:green_frontend/core/error/failures.dart';
import 'package:fpdart/fpdart.dart';
import 'package:green_frontend/features/multiplayer/domain/value_objects/client_role.dart';

enum SessionState { lobby, question, results, end }

abstract interface class MultiplayerSocketRepository {
  // ------------------------------------------------------------
  // CONEXIÓN
  // ------------------------------------------------------------
  Future<Either<Failure, Unit>> connect({
    required ClientRole role,
    required SessionPin pin,
    required String jwt,
  });

  Future<void> disconnect();

  // ------------------------------------------------------------
  // EMISORES (CLIENT → SERVER)
  // ------------------------------------------------------------

  /// Evento: player_join
  void emitPlayerJoin(Nickname nickname);

  /// Evento: host_start_game
  void emitHostStartGame();

  /// Evento: next_phase
  void emitHostNextPhase();

  /// Evento: submit_answer
  void emitPlayerSubmitAnswer({
    required String questionId,
    required AnswerIds answerIds,
    required TimeElapsedMs timeElapsedMs,
  });

  /// Evento: client_ready (handshake)
  void emitClientReady(ClientRole role, SessionPin pin);

  // ------------------------------------------------------------
  // LISTENERS (SERVER → CLIENT)
  // ------------------------------------------------------------

  /// HOST: host_connected_success
  Stream<Unit> get onHostConnectedSuccess;

  /// PLAYER: player_connected_to_session
  /// (NO confundir con player_connected_to_server)
  Stream<Unit> get onPlayerConnectedToSession;

  /// room_joined → confirma que el PIN es válido
  Stream<Either<Failure, Unit>> get onRoomJoined;

  /// host_lobby_update → lista de jugadores
  Stream<HostLobby> get onHostLobbyUpdate;

  /// question_started → slide actual
  Stream<Slide> get onQuestionStarted;

  /// host_results → resultados parciales para el host
  Stream<HostResults> get onHostResults;

  /// player_results → resultados parciales para el jugador
  Stream<PlayerResults> get onPlayerResults;

  /// game_end → resumen final
  Stream<Summary> get onGameEnd;

  /// exception / error
  Stream<Failure> get onSocketError;

  /// session_closed → la sesión terminó
  Stream<Map<String, dynamic>> get onSessionClosed;

  /// player_left → un jugador abandonó la sala
  Stream<String> get onPlayerLeft;

  /// answer_update → conteo de respuestas recibidas
  Stream<int> get onAnswerCountUpdate;
}