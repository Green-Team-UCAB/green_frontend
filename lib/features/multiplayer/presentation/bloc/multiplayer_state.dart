part of 'multiplayer_bloc.dart';

enum MultiplayerStatus { 
  initial, 
  connecting,    // Mientras esperamos la REST o el Socket
  inLobby,       // Ya conectados y esperando jugadores
  inQuestion,    // Viendo una pregunta
  showingResults, // Viendo el podio/resultados de la pregunta
  gameEnded,     // Fin de la partida
  error, 
  sessionClosed 
}

class MultiplayerState extends Equatable {
  final MultiplayerStatus status;
  final ClientRole? role;         // Para saber si somos Host o Player
  final SessionPin? pin;          // El PIN que viene de la REST o del Input
  final HostLobby? lobby;         // Lista de jugadores, etc.
  final Slide? currentSlide;      // La pregunta actual
  final int answersReceived;      // Contador para el Host
  final Failure? failure;         // Para mostrar errores en la UI

  const MultiplayerState({
    this.status = MultiplayerStatus.initial,
    this.role,
    this.pin,
    this.lobby,
    this.currentSlide,
    this.answersReceived = 0,
    this.failure,
  });

  // El copyWith es vital para no perder datos al cambiar de estado
  MultiplayerState copyWith({
    MultiplayerStatus? status,
    ClientRole? role,
    SessionPin? pin,
    HostLobby? lobby,
    Slide? currentSlide,
    int? answersReceived,
    Failure? failure,
  }) {
    return MultiplayerState(
      status: status ?? this.status,
      role: role ?? this.role,
      pin: pin ?? this.pin,
      lobby: lobby ?? this.lobby,
      currentSlide: currentSlide ?? this.currentSlide,
      answersReceived: answersReceived ?? this.answersReceived,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [
        status, 
        role, 
        pin, 
        lobby, 
        currentSlide, 
        answersReceived, 
        failure
      ];
}