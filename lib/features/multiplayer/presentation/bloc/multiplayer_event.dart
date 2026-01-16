part of 'multiplayer_bloc.dart';

abstract class MultiplayerEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Disparado por el HOST al elegir un Kahoot (Pág 54-55)
class OnCreateSessionStarted extends MultiplayerEvent {
  final String kahootId;
  final String jwt;
  
  OnCreateSessionStarted({required this.kahootId, required this.jwt});

  @override
  List<Object?> get props => [kahootId, jwt];
}

/// Disparado por el PLAYER al escanear un QR (Pág 56)
class OnResolvePinStarted extends MultiplayerEvent {
  final String qrToken;
  final String jwt;
  final String nickname;
  OnResolvePinStarted({required this.qrToken, required this.jwt, required this.nickname});

  @override
  List<Object?> get props => [qrToken, jwt, nickname];
}

// --- Eventos disparados por el Usuario (UI) ---
class OnConnectStarted extends MultiplayerEvent {
  final ClientRole role;
  final SessionPin pin;
  final String jwt;
  final String? nickname;
  OnConnectStarted({required this.role, required this.pin, required this.jwt, this.nickname});
}

class _OnHostConnectedSuccess extends MultiplayerEvent {
   _OnHostConnectedSuccess();
}

class _OnPlayerConnectedSuccess extends MultiplayerEvent {
   _OnPlayerConnectedSuccess();
}

class OnJoinRoom extends MultiplayerEvent {
  final Nickname nickname;
  OnJoinRoom(this.nickname);
}

class OnStartGame extends MultiplayerEvent {}
class OnNextPhase extends MultiplayerEvent {}
class OnSubmitAnswer extends MultiplayerEvent {
  final String questionId;
  final AnswerIds answerIds;
  final TimeElapsedMs timeElapsedMs;
  OnSubmitAnswer({required this.questionId, required this.answerIds, required this.timeElapsedMs});
}

// --- Eventos internos disparados por los Streams del Socket ---
class _OnRoomJoinedUpdate extends MultiplayerEvent {
  final Either<Failure, Unit> result;
  _OnRoomJoinedUpdate(this.result);
}

class _OnLobbyUpdate extends MultiplayerEvent {
  final HostLobby lobby;
  _OnLobbyUpdate(this.lobby);
}

class _OnQuestionStarted extends MultiplayerEvent {
  final Slide slide;
  _OnQuestionStarted(this.slide);
}

class _OnAnswerCountUpdate extends MultiplayerEvent {
  final int count;
  _OnAnswerCountUpdate(this.count);
}

class _OnSocketErrorReceived extends MultiplayerEvent {
  final Failure failure;
  _OnSocketErrorReceived(this.failure);
}

class _OnSessionClosedReceived extends MultiplayerEvent {}

class OnResetMultiplayer extends MultiplayerEvent {}

// En multiplayer_event.dart

class _OnQuestionResultsReceived extends MultiplayerEvent {
  final PlayerResults results;
  _OnQuestionResultsReceived(this.results);
}

class _OnGameEndedReceived extends MultiplayerEvent {
  final Summary podium;
  _OnGameEndedReceived(this.podium);
}

// En multiplayer_event.dart
class _OnHostResultsReceived extends MultiplayerEvent {
  final HostResults results;
  _OnHostResultsReceived(this.results);
}

class _OnPlayerConnectedToSession extends MultiplayerEvent {}