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

enum SessionState { lobby, question, results, end }
enum ClientRole { host, player }


abstract interface class MultiplayerSocketRepository {
// conxión al namespace del juego  
  Future<Either<Failure, Unit>> connectToGameSession({required Uri wsBaseUrl, required ClientRole role, required SessionPin pin, required String jwt});
  
/// Señal de sincronización inicial 
  Either<Failure, Unit> emitClientReady();
  
/// --- Eventos que puede emitir el HOST --- 
  Either<Failure, Unit> emitHostStartGame();
  Either<Failure, Unit> emitHostNextPhase(); 
  Either<Failure, Unit> emitHostEndSession();

/// --- Eventos que puede emitir el JUGADOR --- 
  Either<Failure, Unit> emitPlayerJoin(Nickname nickname); 
  Either<Failure, Unit> emitPlayerSubmitAnswer({ required String questionId, required AnswerIds answerIds, required TimeElapsedMs timeElapsedMs, });

/// --- Streams de eventos recibidos del servidor --- 
  Stream<HostLobby> onHostLobbyUpdate(); 
  Stream<Map<String, dynamic>> onPlayerConnectedToSession(); 
  Stream<Slide> onQuestionStarted(); 
  Stream<HostResults> onHostResults(); 
  Stream<PlayerResults> onPlayerResults(); 
  Stream<Summary> onGameEnd(); // sirve tanto para host como jugador 
  Stream<Map<String, String>> onSessionClosed();

/// --- Eventos de fiabilidad/UX extra --- 
  Stream<int> onHostAnswerUpdate(); 
  Stream<String> onPlayerLeftSession(); 
  Stream<String> onHostLeftSession(); 
  Stream<String> onHostReturnedToSession();
  
/// --- Errores --- 
  Stream<String> onGameError(); 
  Stream<String> onConnectionError(); 
  Stream<String> onSyncError();

/// Desconexión del socket
  Future<Either<Failure, Unit>> disconnectFromGameSession();
}