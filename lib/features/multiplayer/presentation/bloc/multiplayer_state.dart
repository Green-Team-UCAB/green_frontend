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
  final DateTime? questionStartTime;
  final bool hasAnswered; // Nuevo campo para saber si el jugador ya respondió
  final PlayerResults? lastQuestionResult; // Resultado de la última pregunta
  final Summary? podium; // Resultados finales al terminar la partida
  final HostResults? lastHostResult;
  
  const MultiplayerState({
    this.status = MultiplayerStatus.initial,
    this.role,
    this.pin,
    this.lobby,
    this.currentSlide,
    this.answersReceived = 0,
    this.failure,
    this.questionStartTime,
    this.hasAnswered = false,
    this.lastQuestionResult,
    this.podium,
    this.lastHostResult,
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
    DateTime? questionStartTime,
    bool? hasAnswered,
    PlayerResults? lastQuestionResult,
    Summary? podium,
    HostResults? lastHostResult,
  }) {
    return MultiplayerState(
      status: status ?? this.status,
      role: role ?? this.role,
      pin: pin ?? this.pin,
      lobby: lobby ?? this.lobby,
      currentSlide: currentSlide ?? this.currentSlide,
      answersReceived: answersReceived ?? this.answersReceived,
      failure: failure ?? this.failure,
      questionStartTime: questionStartTime ?? this.questionStartTime,
      hasAnswered: hasAnswered ?? this.hasAnswered,
      lastQuestionResult: lastQuestionResult ?? this.lastQuestionResult,
      podium: podium ?? this.podium,
      lastHostResult: lastHostResult ?? this.lastHostResult,
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
        failure,
        questionStartTime,
        hasAnswered,
        lastQuestionResult,
        podium,
        lastHostResult,
      ];
}