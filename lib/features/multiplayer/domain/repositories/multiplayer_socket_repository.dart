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
  
  Future<Either<Failure, Unit>> connect({
    required ClientRole role,
    required SessionPin pin,
    required String jwt,
  });
  
  /// Evento 'join_room' 
  void emitPlayerJoin(Nickname nickname);

  /// Evento 'start_game' 
  void emitHostStartGame();

  /// Evento 'next_phase' 
  void emitHostNextPhase();

  /// Evento 'submit_answer' 
  void emitPlayerSubmitAnswer({
    required String questionId,
    required AnswerIds answerIds,
    required TimeElapsedMs timeElapsedMs,
  });

  /// Señal de sincronización (Handshake de Socket.io)
  void emitClientReady(ClientRole role, SessionPin pin);

  /// Desconexión
  Future<void> disconnect();

  /// --- ESCUCHAS (STREAMS) ---
  
  /// Para el HOST: Escucha 'host_connected_success'
  Stream<Unit> get onHostConnectedSuccess;

  /// Para el JUGADOR: Escucha 'player_connected_to_session'
  Stream<Unit> get onPlayerConnectedSuccess;


  /// onRoomJoined: Clave para saber que el PIN fue válido y entraste a la sala
  Stream<Either<Failure, Unit>> get onRoomJoined;

  /// onHostLobbyUpdate: Lista de nicknames para el Host (Pág 58)
  Stream<HostLobby> get onHostLobbyUpdate;

  /// onQuestionStarted (Slide): Recibir la pregunta actual
  Stream<Slide> get onQuestionStarted;

  /// Resultados parciales (Pág 62)
  Stream<HostResults> get onHostResults;
  Stream<PlayerResults> get onPlayerResults;

  /// Fin del juego (Pág 63)
  Stream<Summary> get onGameEnd;

  /// Errores técnicos del socket (Pág 11 de la API: 'exception' o 'error')
  Stream<Failure> get onSocketError;

  // Añadir estos a MultiplayerSocketRepository
  Stream<Map<String, dynamic>> get onSessionClosed;
  Stream<String> get onPlayerLeft;
  Stream<int> get onAnswerCountUpdate; // Cantidad de respuestas recibidas

  
}