import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// Interfaz del DataSource para el Socket.IO

abstract class MultiplayerSocketDataSource {
  Future<void> connect({required String url, required String jwt});
  void emit(String event, dynamic data);
  void disconnect();

  // Streams de datos crudos (Modelos/Maps)
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
  final _roomJoinedController = StreamController<Map<String, dynamic>>.broadcast();
  final _playersUpdateController = StreamController<Map<String, dynamic>>.broadcast();
  final _questionStartedController = StreamController<Map<String, dynamic>>.broadcast();
  final _errorController = StreamController<dynamic>.broadcast();
  final _hostResultsController = StreamController<Map<String, dynamic>>.broadcast();
  final _playerResultsController = StreamController<Map<String, dynamic>>.broadcast();
  final _gameEndController = StreamController<Map<String, dynamic>>.broadcast();
  final _sessionClosedController = StreamController<Map<String, dynamic>>.broadcast();
  final _playerLeftController = StreamController<Map<String, dynamic>>.broadcast();
  final _answerUpdateController = StreamController<Map<String, dynamic>>.broadcast();

  @override
  Future<void> connect({required String url, required String jwt}) async {
    _socket = io.io(url, io.OptionBuilder()
      .setTransports(['websocket']) 
      .setAuth({'token': jwt})      
      .enableAutoConnect()
      .build());

    // 2. Escucha de eventos básicos de conexión
    _socket!.onConnect((_) => print(' Socket Conectado'));
    _socket!.onDisconnect((_) => print(' Socket Desconectado'));

   

    // 3. Mapeo de eventos de la API (Pág 57-60)
    _socket!.on('room_joined', (data) => _roomJoinedController.add(_toMap(data)));
    _socket!.on('player_joined', (data) => _playersUpdateController.add(_toMap(data)));
    _socket!.on('question_started', (data) => _questionStartedController.add(_toMap(data)));
    _socket!.on('host_results', (data) => _hostResultsController.add(_toMap(data)));
    _socket!.on('player_results', (data) => _playerResultsController.add(_toMap(data)));
    _socket!.on('game_end', (data) => _gameEndController.add(_toMap(data)));
    _socket!.on('session_closed', (data) => _sessionClosedController.add(_toMap(data)));
    _socket!.on('player_left', (data) => _playerLeftController.add(_toMap(data)));
    _socket!.on('answer_update', (data) => _answerUpdateController.add(_toMap(data)));
    
    // Captura de excepciones (Pág 64)
    _socket!.on('exception', (data) => _errorController.add(data)); 
    _socket!.onConnectError((data) => _errorController.add(data));
    
    
  }

  // Helper para asegurar que la data es un Map
  Map<String, dynamic> _toMap(dynamic data) {
    if (data is Map) return Map<String, dynamic>.from(data);
    return {};
  }

  @override
  void emit(String event, dynamic data) {
    _socket?.emit(event, data);
  }

  @override
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _closeControllers();
  }

  void _closeControllers() {
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
  Stream<Map<String, dynamic>> get onRoomJoined => _roomJoinedController.stream;
  @override
  Stream<Map<String, dynamic>> get onPlayersUpdate => _playersUpdateController.stream;
  @override
  Stream<Map<String, dynamic>> get onQuestionStarted => _questionStartedController.stream;
  @override
  Stream<Map<String, dynamic>> get onHostResults => _hostResultsController.stream;
  @override
  Stream<Map<String, dynamic>> get onPlayerResults => _playerResultsController.stream;
  @override
  Stream<Map<String, dynamic>> get onGameEnd => _gameEndController.stream;
  @override
  Stream<dynamic> get onError => _errorController.stream;
  @override
  Stream<Map<String, dynamic>> get onSessionClosed => _sessionClosedController.stream;
  @override
  Stream<Map<String, dynamic>> get onPlayerLeft => _playerLeftController.stream;
  @override
  Stream<Map<String, dynamic>> get onAnswerCountUpdate => _answerUpdateController.stream;
}