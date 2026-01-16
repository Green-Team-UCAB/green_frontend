import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// Interfaz del DataSource para el Socket.IO

abstract class MultiplayerSocketDataSource {
  Future<void> connect(
      {required String url,
      required String jwt,
      required String pin,
      required String role});
  void emit(String event, dynamic data);
  void disconnect();

  // Streams de datos crudos (Modelos/Maps)
  Stream<Map<String, dynamic>> get onHostConnectedSuccess;
  Stream<Map<String, dynamic>> get onPlayerConnectedSuccess;
  Stream<Map<String, dynamic>> get onRoomJoined;
  Stream<Map<String, dynamic>> get onPlayersUpdate;
  Stream<Map<String, dynamic>> get onQuestionStarted;
  Stream<Map<String, dynamic>> get onHostResults;
  Stream<Map<String, dynamic>> get onPlayerResults;
  Stream<Map<String, dynamic>> get onGameEnd;
  Stream<dynamic> get onError;
  Stream<Map<String, dynamic>> get onSessionClosed;
  Stream<Map<String, dynamic>> get onPlayerLeft;
  Stream<Map<String, dynamic>> get onAnswerCountUpdate;
}

///Implementación concreta del DataSource
class MultiplayerSocketDataSourceImpl implements MultiplayerSocketDataSource {
  io.Socket? _socket;

  // Controladores para convertir eventos de socket a Streams de Dart
  final _hostConnectedSuccessController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _playerConnectedSuccessController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _roomJoinedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _playersUpdateController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _questionStartedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _errorController = StreamController<dynamic>.broadcast();
  final _hostResultsController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _playerResultsController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _gameEndController = StreamController<Map<String, dynamic>>.broadcast();
  final _sessionClosedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _playerLeftController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _answerUpdateController =
      StreamController<Map<String, dynamic>>.broadcast();

  @override
  @override
  Future<void> connect({
    required String url,
    required String jwt,
    required String pin,
    required String role, // Ahora es dinámico
  }) async {
    final completer = Completer<void>();
    final socketUrl =
        'wss://quizzy-backend-1-zpvc.onrender.com/multiplayer-sessions';

    print('🔍 CONECTANDO COMO: $role AL PIN: $pin');

    _socket = io.io(
        socketUrl,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .enableForceNew()
            .enableAutoConnect()
            // 1. Asegura que el PIN sea un String .toString()
            // 2. Algunos servidores prefieren 'token' en lugar de 'jwt' en el auth
            .setAuth({
              'pin': pin.toString(),
              'role': role.toUpperCase(),
              'jwt': jwt,
            })
            .setQuery({
              'pin': pin.toString(),
              'role': role.toUpperCase(),
              'jwt': jwt,
            })
            .setExtraHeaders({
              'pin': pin.toString(),
              'role': role.toUpperCase(),
              'jwt': jwt,
              'Authorization': 'Bearer $jwt',
            })
            .build());

    // --- MANEJO DE CONEXIÓN FÍSICA ---
    _socket!.onConnect((_) {
      print('✅ [DATASOURCE] Socket Conectado físicamente');
      if (!completer.isCompleted) completer.complete();
    });

    _socket!.onConnectError((data) {
      print('❌ [DATASOURCE] Error de conexión: $data');
      if (!completer.isCompleted) completer.completeError(data);
    });

    _socket!.onDisconnect(
        (reason) => print('🔌 [DATASOURCE] Socket Desconectado $reason'));

    // Esto te dirá si el PIN es inválido o el JWT expiró
    _socket!.on('exception', (data) {
      print('⚠️ EXCEPCIÓN DEL SERVIDOR: $data');
    });

// Esto te dirá si hay un error de protocolo
    _socket!.onConnectError((data) {
      print('❌ ERROR DE PROTOCOLO: $data');
    });

    // --- DEBUG: ATRAPA-TODO ---
    _socket!.onAny((event, data) {
      print('📩 [SOCKET_EVENT]: $event | Data: $data');
    });

    // --- MAPEOS SEGÚN PÁG 58-64 ---
    _socket!.on('host_connected_success',
        (data) => _hostConnectedSuccessController.add(_toMap(data)));
    _socket!.on('player_connected_to_server',
        (data) => _playerConnectedSuccessController.add(_toMap(data)));
    _socket!.on('host_lobby_update',
        (data) => _playersUpdateController.add(_toMap(data)));

    // Otros eventos
    _socket!
        .on('room_joined', (data) => _roomJoinedController.add(_toMap(data)));
    _socket!.on(
        'player_joined', (data) => _playersUpdateController.add(_toMap(data)));
    _socket!.on('question_started', (data) {
      print(
          "✅ [DATASOURCE] HANDLER: question_started detected! Data received: $data");
      _questionStartedController.add(_toMap(data));
    });
    _socket!
        .on('host_results', (data) => _hostResultsController.add(_toMap(data)));
    _socket!.on(
        'player_results', (data) => _playerResultsController.add(_toMap(data)));
    _socket!.on('game_end', (data) => _gameEndController.add(_toMap(data)));
    _socket!.on(
        'session_closed', (data) => _sessionClosedController.add(_toMap(data)));
    _socket!
        .on('player_left', (data) => _playerLeftController.add(_toMap(data)));
    _socket!.on(
        'answer_update', (data) => _answerUpdateController.add(_toMap(data)));

    _socket!.on('exception', (data) => _errorController.add(data));

    // Esperar a que el evento onConnect ocurra antes de seguir
    return completer.future;
  }

  // Helper para asegurar que la data es un Map
  Map<String, dynamic> _toMap(dynamic data) {
    if (data is Map) return Map<String, dynamic>.from(data);
    return {};
  }

  @override
  void emit(String event, dynamic data) {
    print('📤 [EMIT]: $event | Data: $data');
    _socket?.emit(event, data);
  }

  @override
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _closeControllers();
  }

  void _closeControllers() {
    _hostConnectedSuccessController.close();
    _playerConnectedSuccessController.close();
    _roomJoinedController.close();
    _playersUpdateController.close();
    _questionStartedController.close();
    _errorController.close();
    _hostResultsController.close();
    _playerResultsController.close();
    _gameEndController.close();
    _sessionClosedController.close();
    _playerLeftController.close();
    _answerUpdateController.close();
  }

  // Getters de los Streams
  @override
  Stream<Map<String, dynamic>> get onHostConnectedSuccess =>
      _hostConnectedSuccessController.stream;
  @override
  Stream<Map<String, dynamic>> get onPlayerConnectedSuccess =>
      _playerConnectedSuccessController.stream;
  @override
  Stream<Map<String, dynamic>> get onRoomJoined => _roomJoinedController.stream;
  @override
  Stream<Map<String, dynamic>> get onPlayersUpdate =>
      _playersUpdateController.stream;
  @override
  Stream<Map<String, dynamic>> get onQuestionStarted =>
      _questionStartedController.stream;
  @override
  Stream<Map<String, dynamic>> get onHostResults =>
      _hostResultsController.stream;
  @override
  Stream<Map<String, dynamic>> get onPlayerResults =>
      _playerResultsController.stream;
  @override
  Stream<Map<String, dynamic>> get onGameEnd => _gameEndController.stream;
  @override
  Stream<dynamic> get onError => _errorController.stream;
  @override
  Stream<Map<String, dynamic>> get onSessionClosed =>
      _sessionClosedController.stream;
  @override
  Stream<Map<String, dynamic>> get onPlayerLeft => _playerLeftController.stream;
  @override
  Stream<Map<String, dynamic>> get onAnswerCountUpdate =>
      _answerUpdateController.stream;
}
