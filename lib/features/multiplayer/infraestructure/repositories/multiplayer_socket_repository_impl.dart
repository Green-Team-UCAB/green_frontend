import 'dart:async';
import 'package:fpdart/fpdart.dart';
import 'package:green_frontend/core/error/failures.dart';
import 'package:green_frontend/features/multiplayer/domain/repositories/multiplayer_socket_repository.dart';
import 'package:green_frontend/features/multiplayer/infraestructure/datasources/multiplayer_socket_datasource.dart';
import 'package:green_frontend/features/multiplayer/infraestructure/models/host_lobby.dart';
import 'package:green_frontend/features/multiplayer/infraestructure/models/slide_model.dart';
import 'package:green_frontend/features/multiplayer/domain/value_objects/session_pin.dart';
import 'package:green_frontend/features/multiplayer/domain/value_objects/nickname.dart';
import 'package:green_frontend/features/multiplayer/domain/value_objects/answer_id.dart';
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
  final String baseUrl;

  MultiplayerSocketRepositoryImpl(
      {required this.dataSource, required this.baseUrl});

  @override
  Future<Either<Failure, Unit>> connect({
    required ClientRole role,
    required SessionPin pin,
    required String jwt,
  }) async {
    print("DEBUG: Conectando con URL: $baseUrl");
    try {
      // CONVERSIÓN AQUÍ: Pasamos el nombre del rol en mayúsculas
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

  // --- EMISORES (Acciones del usuario) ---

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
    dataSource.emit('host_start_game', {});
  }

  // --- ESCUCHAS (Transformación de Datos) ---

  @override
  Stream<Unit> get onHostConnectedSuccess =>
      dataSource.onHostConnectedSuccess.map((_) => unit);

  @override
  Stream<Unit> get onPlayerConnectedSuccess =>
      dataSource.onPlayerConnectedSuccess.map((_) => unit);

  @override
  Stream<Either<Failure, Unit>> get onRoomJoined =>
      dataSource.onRoomJoined.map((data) => right(unit));

  @override
  Stream<HostLobby> get onHostLobbyUpdate => dataSource.onPlayersUpdate
      .map((data) => HostLobbyModel.fromJson(data).toEntity());

  // 🔥 TRAMPA DE DEPURACIÓN ACTIVADA 🔥
  @override
  Stream<Slide> get onQuestionStarted {
    print("✅ [REPO] onQuestionStarted getter called. returning mapped stream.");
    return dataSource.onQuestionStarted.map((data) {
      print("\n🛑 [DEBUG REPO] --- INICIO PROCESAMIENTO PREGUNTA ---");
      print("🛑 [DEBUG REPO] 1. Data cruda recibida del Socket: $data");

      try {
        // 1. Extracción de datos
        Map<String, dynamic> slideMap;

        if (data.containsKey('currentSlideData')) {
          print(
              "🛑 [DEBUG REPO] 2. Detectado 'currentSlideData', extrayendo...");
          // Aseguramos que sea un Mapa de String, dynamic
          slideMap = Map<String, dynamic>.from(data['currentSlideData']);
        } else {
          print(
              "🛑 [DEBUG REPO] 2. Usando data plana (no hay currentSlideData)...");
          slideMap = Map<String, dynamic>.from(data);
        }

        print(
            "🛑 [DEBUG REPO] 3. Data final para SlideModel.fromJson: $slideMap");

        // 2. Intento de conversión (Aquí suele fallar)
        print("🛑 [DEBUG REPO] 4. Ejecutando SlideModel.fromJson...");
        final model = SlideModel.fromJson(slideMap);

        print(
            "✅ [DEBUG REPO] 5. Conversión EXITOSA. Pregunta: ${model.questionText}");
        print("🛑 [DEBUG REPO] --- FIN PROCESAMIENTO PREGUNTA ---\n");
        return model.toEntity();
      } catch (e, stackTrace) {
        // 3. Captura del error
        print("\n❌❌❌ [CRITICAL ERROR] FALLÓ SlideModel.fromJson ❌❌❌");
        print("❌ TIPO DE ERROR: ${e.runtimeType}");
        print("❌ MENSAJE: $e");
        print("❌ stackTrace: $stackTrace");
        print("❌❌❌ REVISA TU SlideModel Y OptionModel ❌❌❌\n");

        throw FormatException("Error crítico parseando Slide: $e");
      }
    });
  }

  @override
  Stream<HostResults> get onHostResults => dataSource.onHostResults
      .where((data) => data.isNotEmpty) // evita {}
      .map((data) => HostResultModel.fromJson(data).toEntity());

  @override
  Stream<PlayerResults> get onPlayerResults => dataSource.onPlayerResults
      .map((data) => PlayerResultsModel.fromJson(data).toEntity());

  @override
  Stream<Summary> get onGameEnd => dataSource.onGameEnd
      .map((data) => SummaryModel.fromJson(data).toEntity());

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

  @override
  Future<void> disconnect() async {
    dataSource.disconnect();
  }
}
