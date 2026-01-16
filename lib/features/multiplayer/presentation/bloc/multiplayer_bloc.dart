import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

// Commands
import 'package:green_frontend/features/multiplayer/application/commands.dart';

// Listeners
import 'package:green_frontend/features/multiplayer/application/subscriptions.dart';

// Domain
import 'package:green_frontend/features/multiplayer/domain/entities/host_lobby.dart';
import 'package:green_frontend/features/multiplayer/domain/entities/slide.dart';
import 'package:green_frontend/features/multiplayer/domain/value_objects/session_pin.dart';
import 'package:green_frontend/features/multiplayer/domain/value_objects/nickname.dart';
import 'package:green_frontend/features/multiplayer/domain/value_objects/answer_id.dart';
import 'package:green_frontend/features/multiplayer/domain/value_objects/time_elapsed_ms.dart';
import 'package:green_frontend/features/multiplayer/domain/value_objects/qr_token.dart';
import 'package:green_frontend/features/multiplayer/domain/value_objects/client_role.dart';
import 'package:green_frontend/features/multiplayer/domain/entities/player_results.dart';
import 'package:green_frontend/features/multiplayer/domain/entities/summary.dart';
import 'package:green_frontend/features/multiplayer/domain/entities/host_result.dart';
import 'package:green_frontend/core/error/failures.dart';

part 'multiplayer_event.dart';
part 'multiplayer_state.dart';

class MultiplayerBloc extends Bloc<MultiplayerEvent, MultiplayerState> {
  // REST
  final CreateMultiplayerSession _createSession;
  final ResolvePinFromQr _resolvePinFromQr;

  // Commands
  final ConnectToGame _connectToGame;
  final ConfirmClientReady _confirmClientReady;
  final JoinRoom _joinRoom;
  final StartGame _startGame;
  final NextPhase _nextPhase;
  final SubmitSyncAnswer _submitAnswer;

  // Listeners
  final ListenHostConnectedSuccess _listenHostSuccess;
  final ListenPlayerConnectedToSession _listenPlayerConnectedToSession;
  final ListenRoomJoined _listenRoomJoined;
  final ListenHostLobbyUpdate _listenHostLobbyUpdate;
  final ListenQuestionStarted _listenQuestionStarted;
  final ListenAnswerUpdate _listenAnswerCountUpdate;
  final ListenSocketError _listenSocketError;
  final ListenSessionClosed _listenSessionClosed;
  final ListenPlayerResults _listenPlayerResults;
  final ListenGameEnd _listenGameEnd;
  final ListenHostResults _listenHostResults;

  // Subscriptions
  StreamSubscription? _hostSuccessSub;
  StreamSubscription? _playerConnectedToSessionSub;
  StreamSubscription? _roomJoinedSub;
  StreamSubscription? _lobbySub;
  StreamSubscription? _questionSub;
  StreamSubscription? _answerCountSub;
  StreamSubscription? _errorSub;
  StreamSubscription? _sessionClosedSub;
  StreamSubscription? _resultsSub;
  StreamSubscription? _gameEndedSub;
  StreamSubscription? _hostResultsSub;

  MultiplayerBloc({
    required CreateMultiplayerSession createSession,
    required ResolvePinFromQr resolvePinFromQr,
    required ConnectToGame connectToGame,
    required ConfirmClientReady confirmClientReady,
    required JoinRoom joinRoom,
    required StartGame startGame,
    required NextPhase nextPhase,
    required SubmitSyncAnswer submitAnswer,
    required ListenHostConnectedSuccess listenHostSuccess,
    required ListenPlayerConnectedToSession listenPlayerConnectedToSession,
    required ListenRoomJoined listenRoomJoined,
    required ListenHostLobbyUpdate listenHostLobbyUpdate,
    required ListenQuestionStarted listenQuestionStarted,
    required ListenAnswerUpdate listenAnswerCountUpdate,
    required ListenSocketError listenSocketError,
    required ListenSessionClosed listenSessionClosed,
    required ListenPlayerResults listenPlayerResults,
    required ListenGameEnd listenGameEnd,
    required ListenHostResults listenHostResults,
  })  : _createSession = createSession,
        _resolvePinFromQr = resolvePinFromQr,
        _connectToGame = connectToGame,
        _confirmClientReady = confirmClientReady,
        _joinRoom = joinRoom,
        _startGame = startGame,
        _nextPhase = nextPhase,
        _submitAnswer = submitAnswer,
        _listenHostSuccess = listenHostSuccess,
        _listenPlayerConnectedToSession = listenPlayerConnectedToSession,
        _listenRoomJoined = listenRoomJoined,
        _listenHostLobbyUpdate = listenHostLobbyUpdate,
        _listenQuestionStarted = listenQuestionStarted,
        _listenAnswerCountUpdate = listenAnswerCountUpdate,
        _listenSocketError = listenSocketError,
        _listenSessionClosed = listenSessionClosed,
        _listenPlayerResults = listenPlayerResults,
        _listenGameEnd = listenGameEnd,
        _listenHostResults = listenHostResults,
        super(const MultiplayerState()) {
    // REST + socket connect
    on<OnCreateSessionStarted>(_onCreateSessionStarted);
    on<OnResolvePinStarted>(_onResolvePinStarted);
    on<OnConnectStarted>(_onConnectStarted);

    // Commands
    on<OnJoinRoom>(_onJoinRoom);
    on<OnStartGame>(_onStartGame);
    on<OnNextPhase>(_onNextPhase);
    on<OnSubmitAnswer>(_onSubmitAnswer);

    // Socket events
    on<_OnHostConnectedSuccess>((event, emit) {
      emit(state.copyWith(status: MultiplayerStatus.inLobby));
    });

    on<_OnPlayerConnectedToSession>((event, emit) {
      emit(state.copyWith(status: MultiplayerStatus.inLobby));
    });

    on<_OnRoomJoinedUpdate>((event, emit) {
      emit(state.copyWith(status: MultiplayerStatus.inLobby));
    });

    on<_OnLobbyUpdate>((event, emit) {
      emit(state.copyWith(
        lobby: event.lobby,
        status: MultiplayerStatus.inLobby,
      ));
    });

    on<_OnQuestionStarted>((event, emit) {
      emit(state.copyWith(
        currentSlide: event.slide,
        status: MultiplayerStatus.inQuestion,
        answersReceived: 0,
        hasAnswered: false,
        questionStartTime: DateTime.now(),
      ));
    });

    on<_OnAnswerCountUpdate>((event, emit) {
      emit(state.copyWith(answersReceived: event.count));
    });

    on<_OnSocketErrorReceived>((event, emit) {
      emit(state.copyWith(status: MultiplayerStatus.error, failure: event.failure));
    });

    on<_OnSessionClosedReceived>((event, emit) {
      emit(state.copyWith(status: MultiplayerStatus.sessionClosed));
    });

    on<_OnQuestionResultsReceived>((event, emit) {
      emit(state.copyWith(
        status: MultiplayerStatus.showingResults,
        lastQuestionResult: event.results,
      ));
    });

    on<_OnGameEndedReceived>((event, emit) {
      emit(state.copyWith(
        status: MultiplayerStatus.gameEnded,
        podium: event.podium,
      ));
    });

    on<_OnHostResultsReceived>((event, emit) {
      emit(state.copyWith(
        status: MultiplayerStatus.showingResults,
        lastHostResult: event.results,
      ));
    });

    on<OnResetMultiplayer>(_onResetMultiplayer);
  }

  // ---------------------------------------------------------------------------
  // REST + CONNECT
  // ---------------------------------------------------------------------------

  Future<void> _onCreateSessionStarted(
      OnCreateSessionStarted event, Emitter<MultiplayerState> emit) async {
    emit(state.copyWith(status: MultiplayerStatus.connecting));

    final result = await _createSession(
      kahootId: event.kahootId,
      jwt: event.jwt,
    );

    result.fold(
      (failure) => add(_OnSocketErrorReceived(failure)),
      (session) {
        emit(state.copyWith(pin: session.sessionPin));

        add(OnConnectStarted(
          role: ClientRole.host,
          pin: session.sessionPin,
          jwt: event.jwt,
        ));
      },
    );
  }

  Future<void> _onResolvePinStarted(
      OnResolvePinStarted event, Emitter<MultiplayerState> emit) async {
    emit(state.copyWith(status: MultiplayerStatus.connecting));

    final result = await _resolvePinFromQr(qrToken: QrToken(event.qrToken));

    result.fold(
      (failure) => add(_OnSocketErrorReceived(failure)),
      (sessionPin) {
        add(OnConnectStarted(
          role: ClientRole.player,
          pin: sessionPin,
          jwt: event.jwt,
          nickname: event.nickname,
        ));
      },
    );
  }

  Future<void> _onConnectStarted(
      OnConnectStarted event, Emitter<MultiplayerState> emit) async {
    Nickname? validNickname;

    if (event.role == ClientRole.player) {
      final name = event.nickname?.trim() ?? "";
      if (name.length < 6 || name.length > 20) {
        emit(state.copyWith(
          status: MultiplayerStatus.error,
          failure: const ServerFailure(
              "El nickname debe tener entre 6 y 20 caracteres"),
        ));
        return;
      }
      validNickname = Nickname(event.nickname!);
    }

    emit(state.copyWith(
      status: MultiplayerStatus.connecting,
      pin: event.pin,
      role: event.role,
    ));

    final result =
        await _connectToGame(role: event.role, pin: event.pin, jwt: event.jwt);

    await result.fold(
      (failure) async => add(_OnSocketErrorReceived(failure)),
      (_) async {
        _cancelAllSubscriptions();
        _initSubscriptions();

        await Future.delayed(const Duration(milliseconds: 500));

        _confirmClientReady(event.role, event.pin);

        if (event.role == ClientRole.player && validNickname != null) {
          add(OnJoinRoom(validNickname));
        }
      },
    );
  }

  // ---------------------------------------------------------------------------
  // SUBSCRIPTIONS
  // ---------------------------------------------------------------------------

  void _initSubscriptions() {
    _hostSuccessSub =
        _listenHostSuccess().listen((_) => add(_OnHostConnectedSuccess()));

    _playerConnectedToSessionSub = _listenPlayerConnectedToSession()
        .listen((_) => add(_OnPlayerConnectedToSession()));

    _roomJoinedSub =
        _listenRoomJoined().listen((res) => add(_OnRoomJoinedUpdate(res)));

    _lobbySub = _listenHostLobbyUpdate().listen((lobby) {
      add(_OnLobbyUpdate(lobby));
    });

    _questionSub =
        _listenQuestionStarted().listen((slide) => add(_OnQuestionStarted(slide)));

    _answerCountSub = _listenAnswerCountUpdate()
        .listen((count) => add(_OnAnswerCountUpdate(count)));

    _resultsSub = _listenPlayerResults()
        .listen((results) => add(_OnQuestionResultsReceived(results)));

    _gameEndedSub =
        _listenGameEnd().listen((podium) => add(_OnGameEndedReceived(podium)));

    _errorSub = _listenSocketError()
        .listen((failure) => add(_OnSocketErrorReceived(failure)));

    _sessionClosedSub =
        _listenSessionClosed().listen((_) => add(_OnSessionClosedReceived()));

    if (state.role == ClientRole.host) {
      _hostResultsSub = _listenHostResults()
          .listen((results) => add(_OnHostResultsReceived(results)));
    }
  }

  // ---------------------------------------------------------------------------
  // COMMANDS
  // ---------------------------------------------------------------------------

  Future<void> _onJoinRoom(
          OnJoinRoom event, Emitter<MultiplayerState> emit) async =>
      await _joinRoom(event.nickname);

  Future<void> _onStartGame(
          OnStartGame event, Emitter<MultiplayerState> emit) async =>
      await _startGame();

  Future<void> _onNextPhase(
          OnNextPhase event, Emitter<MultiplayerState> emit) async =>
      await _nextPhase();

  Future<void> _onSubmitAnswer(
      OnSubmitAnswer event, Emitter<MultiplayerState> emit) async {
    emit(state.copyWith(hasAnswered: true));
    await _submitAnswer(
      questionId: event.questionId,
      answerIds: event.answerIds,
      timeElapsedMs: event.timeElapsedMs,
    );
  }

  // ---------------------------------------------------------------------------
  // RESET
  // ---------------------------------------------------------------------------

  void _onResetMultiplayer(
      OnResetMultiplayer event, Emitter<MultiplayerState> emit) {
    _cancelAllSubscriptions();
    emit(const MultiplayerState());
  }

  void _cancelAllSubscriptions() {
    _hostSuccessSub?.cancel();
    _playerConnectedToSessionSub?.cancel();
    _roomJoinedSub?.cancel();
    _lobbySub?.cancel();
    _questionSub?.cancel();
    _answerCountSub?.cancel();
    _errorSub?.cancel();
    _sessionClosedSub?.cancel();
    _resultsSub?.cancel();
    _gameEndedSub?.cancel();
    _hostResultsSub?.cancel();
  }

  @override
  Future<void> close() {
    _cancelAllSubscriptions();
    return super.close();
  }
}