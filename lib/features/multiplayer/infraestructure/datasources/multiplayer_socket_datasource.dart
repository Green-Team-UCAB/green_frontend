import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// Interfaz del DataSource para el Socket.IO
abstract class MultiplayerSocketDataSource {
  Future<void> connect({
    required String url,
    required String jwt,
    required String pin,
    required String role,
  });

  void emit(String event, dynamic data);
  void disconnect();

  // Streams de datos crudos (Modelos/Maps)
  Stream<Map<String, dynamic>> get onHostConnectedSuccess;
  Stream<Map<String, dynamic>> get onPlayerConnectedToSession;
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

/// Implementación concreta del DataSource
class MultiplayerSocketDataSourceImpl implements MultiplayerSocketDataSource {
  io.Socket? _socket;

  // Controladores
  final _hostConnectedSuccessController =
      StreamController<Map<String, dynamic>>.broadcast();

  final _playerConnectedToSessionController =
      StreamController<Map<String, dynamic>>.broadcast();

  final _roomJoinedController =
      StreamController<Map<String, dynamic>>.broadcast();

  final _playersUpdateController =
      StreamController<Map<String, dynamic>>.broadcast();

  final _questionStartedController =
      StreamController<Map<String, dynamic>>.broadcast();

  final _hostResultsController =
      StreamController<Map<String, dynamic>>.broadcast();

  final _playerResultsController =
      StreamController<Map<String, dynamic>>.broadcast();

  final _gameEndController =
      StreamController<Map<String, dynamic>>.broadcast();

  final _sessionClosedController =
      StreamController<Map<String, dynamic>>.broadcast();

  final _playerLeftController =
      StreamController<Map<String, dynamic>>.broadcast();

  final _answerUpdateController =
      StreamController<Map<String, dynamic>>.broadcast();

  final _errorController = StreamController<dynamic>.broadcast();

  @override
  Future<void> connect({
    required String url,
    required String jwt,
    required String pin,
    required String role,
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
          .setAuth({
            'pin': pin,
            'role': role.toUpperCase(),
            'jwt': jwt,
          })
          .setQuery({
            'pin': pin,
            'role': role.toUpperCase(),
            'jwt': jwt,
          })
          .setExtraHeaders({
            'pin': pin,
            'role': role.toUpperCase(),
            'jwt': jwt,
            'Authorization': 'Bearer $jwt',
          })
          .build(),
    );

    // Conexión física
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

    // Excepciones del servidor
    _socket!.on('exception', (data) {
      print('⚠️ EXCEPCIÓN DEL SERVIDOR: $data');
      _errorController.add(data);
    });

    // Debug: atrapa todo
    _socket!.onAny((event, data) {
      print('📩 [SOCKET_EVENT]: $event | Data: $data');
    });

    // -----------------------------
    // MAPEOS OFICIALES API
    // -----------------------------

    // HOST
    _socket!.on('host_connected_success',
        (data) => _hostConnectedSuccessController.add(_toMap(data)));

    // PLAYER (conexión lógica)
    _socket!.on('player_connected_to_session',
        (data) => _playerConnectedToSessionController.add(_toMap(data)));

    // LOBBY
    _socket!.on('host_lobby_update',
        (data) => _playersUpdateController.add(_toMap(data)));

    _socket!.on('player_joined',
        (data) => _playersUpdateController.add(_toMap(data)));

    // ROOM JOINED
    _socket!.on('room_joined',
        (data) => _roomJoinedController.add(_toMap(data)));

    // QUESTION STARTED
    // datasource
    _socket!.on('question_started', (data) {
  final map = _toMap(data);
  final slide = map['currentSlideData'] ?? {};
  _questionStartedController.add(Map<String, dynamic>.from(slide));
});

    // RESULTS
    _socket!.on('host_results',
        (data) => _hostResultsController.add(_toMap(data)));

    _socket!.on('player_results',
        (data) => _playerResultsController.add(_toMap(data)));

    // GAME END
    _socket!.on('game_end', (data) => _gameEndController.add(_toMap(data)));

    // SESSION CLOSED
    _socket!.on('session_closed',
        (data) => _sessionClosedController.add(_toMap(data)));

    // PLAYER LEFT
    _socket!.on('player_left',
        (data) => _playerLeftController.add(_toMap(data)));

    // ANSWER UPDATE
    _socket!.on('answer_update',
        (data) => _answerUpdateController.add(_toMap(data)));

    return completer.future;
  }

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
    _playerConnectedToSessionController.close();
    _roomJoinedController.close();
    _playersUpdateController.close();
    _questionStartedController.close();
    _hostResultsController.close();
    _playerResultsController.close();
    _gameEndController.close();
    _sessionClosedController.close();
    _playerLeftController.close();
    _answerUpdateController.close();
    _errorController.close();
  }

  // -----------------------------
  // GETTERS
  // -----------------------------

  @override
  Stream<Map<String, dynamic>> get onHostConnectedSuccess =>
      _hostConnectedSuccessController.stream;

  @override
  Stream<Map<String, dynamic>> get onPlayerConnectedToSession =>
      _playerConnectedToSessionController.stream;

  @override
  Stream<Map<String, dynamic>> get onRoomJoined =>
      _roomJoinedController.stream;

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
  Stream<Map<String, dynamic>> get onPlayerLeft =>
      _playerLeftController.stream;

  @override
  Stream<Map<String, dynamic>> get onAnswerCountUpdate =>
      _answerUpdateController.stream;
}