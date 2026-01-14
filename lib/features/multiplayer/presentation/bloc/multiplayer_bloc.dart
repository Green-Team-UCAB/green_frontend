import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:green_frontend/features/multiplayer/application/commands.dart';
import 'package:green_frontend/features/multiplayer/application/subscriptions.dart';
import 'package:green_frontend/features/multiplayer/domain/entities/host_lobby.dart';
import 'package:green_frontend/features/multiplayer/domain/entities/slide.dart';
import 'package:green_frontend/features/multiplayer/domain/value_objects/session_pin.dart';
import 'package:green_frontend/features/multiplayer/domain/value_objects/nickname.dart';
import 'package:green_frontend/features/multiplayer/domain/value_objects/answer_id.dart';
import 'package:green_frontend/features/multiplayer/domain/value_objects/time_elapsed_ms.dart';
import 'package:green_frontend/core/error/failures.dart';
import 'package:green_frontend/features/multiplayer/domain/value_objects/qr_token.dart';
import 'package:green_frontend/features/multiplayer/domain/value_objects/client_role.dart';
import 'package:fpdart/fpdart.dart';
part 'multiplayer_event.dart';
part 'multiplayer_state.dart';



class MultiplayerBloc extends Bloc<MultiplayerEvent, MultiplayerState> {
  // --- Casos de Uso REST (Nuevos) ---
  final CreateMultiplayerSession _createSession;
  final ResolvePinFromQr _resolvePinFromQr;
 
  // Comandos sockets
  final ConnectToGame _connectToGame;
  final JoinRoom _joinRoom;
  final StartGame _startGame;
  final NextPhase _nextPhase;
  final SubmitSyncAnswer _submitAnswer;

  // Suscripciones
  final ListenRoomJoined _listenRoomJoined;
  final ListenHostLobbyUpdate _listenHostLobbyUpdate;
  final ListenQuestionStarted _listenQuestionStarted;
  final ListenAnswerUpdate _listenAnswerCountUpdate;
  final ListenSocketError _listenSocketError;
  final ListenSessionClosed _listenSessionClosed;

  StreamSubscription? _roomJoinedSub;
  StreamSubscription? _lobbySub;
  StreamSubscription? _questionSub;
  StreamSubscription? _answerCountSub;
  StreamSubscription? _errorSub;
  StreamSubscription? _sessionClosedSub;

  MultiplayerBloc({
    required CreateMultiplayerSession createSession,
    required ResolvePinFromQr resolvePinFromQr,
    required ConnectToGame connectToGame,
    required JoinRoom joinRoom,
    required StartGame startGame,
    required NextPhase nextPhase,
    required SubmitSyncAnswer submitAnswer,
    required ListenRoomJoined listenRoomJoined,
    required ListenHostLobbyUpdate listenHostLobbyUpdate,
    required ListenQuestionStarted listenQuestionStarted,
    required ListenAnswerUpdate listenAnswerCountUpdate,
    required ListenSocketError listenSocketError,
    required ListenSessionClosed listenSessionClosed,
  })  : _createSession = createSession,
        _resolvePinFromQr = resolvePinFromQr,
        _connectToGame = connectToGame,
        _joinRoom = joinRoom,
        _startGame = startGame,
        _nextPhase = nextPhase,
        _submitAnswer = submitAnswer,
        _listenRoomJoined = listenRoomJoined,
        _listenHostLobbyUpdate = listenHostLobbyUpdate,
        _listenQuestionStarted = listenQuestionStarted,
        _listenAnswerCountUpdate = listenAnswerCountUpdate,
        _listenSocketError = listenSocketError,
        _listenSessionClosed = listenSessionClosed,
        super(const MultiplayerState()) {
    
    // Eventos de Inicio (REST + Socket)
    on<OnCreateSessionStarted>(_onCreateSessionStarted);
    on<OnResolvePinStarted>(_onResolvePinStarted);
    on<OnConnectStarted>(_onConnectStarted);

    on<OnJoinRoom>(_onJoinRoom);
    on<OnStartGame>(_onStartGame);
    on<OnNextPhase>(_onNextPhase);
    on<OnSubmitAnswer>(_onSubmitAnswer);
    
    // Mapeo de eventos de Socket
    on<_OnRoomJoinedUpdate>((event, emit) => emit(state.copyWith(status: MultiplayerStatus.inLobby)));
    on<_OnLobbyUpdate>((event, emit) => emit(state.copyWith(lobby: event.lobby, status: MultiplayerStatus.inLobby)));
    on<_OnQuestionStarted>((event, emit) => emit(state.copyWith(currentSlide: event.slide, status: MultiplayerStatus.inQuestion, answersReceived: 0)));
    on<_OnAnswerCountUpdate>((event, emit) => emit(state.copyWith(answersReceived: event.count)));
    on<_OnSocketErrorReceived>((event, emit) => emit(state.copyWith(status: MultiplayerStatus.error, failure: event.failure)));
    on<_OnSessionClosedReceived>((event, emit) => emit(state.copyWith(status: MultiplayerStatus.sessionClosed)));
  }

  // 1. Lógica para el HOST (Pág 54-55)
  Future<void> _onCreateSessionStarted(OnCreateSessionStarted event, Emitter<MultiplayerState> emit) async {
    emit(state.copyWith(status: MultiplayerStatus.connecting));
    
    final result = await _createSession(kahootId:event.kahootId, jwt: event.jwt);
    
    result.fold(
      (failure) => add(_OnSocketErrorReceived(failure)),
      (session) {
        emit(state.copyWith(pin: session.sessionPin));
        // Una vez creada la sesión REST, conectamos automáticamente el Socket
        add(OnConnectStarted(
          role: ClientRole.host, 
          pin: session.sessionPin, 
          jwt: event.jwt
        ));
      },
    );
  }

  // 2. Lógica para el PLAYER vía QR (Pág 56)
  Future<void> _onResolvePinStarted(OnResolvePinStarted event, Emitter<MultiplayerState> emit) async {
    emit(state.copyWith(status: MultiplayerStatus.connecting));

    final result = await _resolvePinFromQr(qrToken: QrToken(event.qrToken));
    
    result.fold(
      (failure) => add(_OnSocketErrorReceived(failure)),
      (sessionPin) {
        add(OnConnectStarted(
          role: ClientRole.player, 
          pin: sessionPin, 
          jwt: event.jwt
        ));
      },
    );
  }

  Future<void> _onConnectStarted(OnConnectStarted event, Emitter<MultiplayerState> emit) async {
    emit(state.copyWith(status: MultiplayerStatus.connecting));
    
    // 1. Iniciar conexión física
    final result = await _connectToGame(role: event.role, pin: event.pin, jwt: event.jwt);
    
    result.fold(
      (failure) => add(_OnSocketErrorReceived(failure)),
      (_) {
        // 2. Si conecta, activamos todas las escuchas de la API (Pág 57-74)
        _initSubscriptions();
        emit(state.copyWith(status: MultiplayerStatus.inLobby));
      },
    );
  }

  void _initSubscriptions() {
    _roomJoinedSub = _listenRoomJoined().listen((res) => add(_OnRoomJoinedUpdate(res)));
    _lobbySub = _listenHostLobbyUpdate().listen((lobby) => add(_OnLobbyUpdate(lobby)));
    _questionSub = _listenQuestionStarted().listen((slide) => add(_OnQuestionStarted(slide)));
    _answerCountSub = _listenAnswerCountUpdate().listen((count) => add(_OnAnswerCountUpdate(count)));
    _errorSub = _listenSocketError().listen((fail) => add(_OnSocketErrorReceived(fail)));
    _sessionClosedSub = _listenSessionClosed().listen((_) => add(_OnSessionClosedReceived()));
  }

  // --- Lógica de Comandos ---
  Future<void> _onJoinRoom(OnJoinRoom event, Emitter<MultiplayerState> emit) async => await _joinRoom(event.nickname);
  Future<void> _onStartGame(OnStartGame event, Emitter<MultiplayerState> emit) async => await _startGame();
  Future<void> _onNextPhase(OnNextPhase event, Emitter<MultiplayerState> emit) async => await _nextPhase();
  Future<void> _onSubmitAnswer(OnSubmitAnswer event, Emitter<MultiplayerState> emit) async {
    await _submitAnswer(questionId: event.questionId, answerIds: event.answerIds, timeElapsedMs: event.timeElapsedMs);
  }

  @override
  Future<void> close() {
    _roomJoinedSub?.cancel();
    _lobbySub?.cancel();
    _questionSub?.cancel();
    _answerCountSub?.cancel();
    _errorSub?.cancel();
    _sessionClosedSub?.cancel();
    return super.close();
  }
}