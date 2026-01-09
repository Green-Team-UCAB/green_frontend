import 'package:green_frontend/features/single_player/domain/entities/answer.dart';



abstract class GameEvent {}

class StartGame extends GameEvent {
  final String kahootId;
  StartGame(this.kahootId);
}

class SubmitAnswerEvent extends GameEvent {
  final String attemptId;
  final Answer answer;
  SubmitAnswerEvent(this.attemptId, this.answer);
}

class FinishGame extends GameEvent {
  final String attemptId;
  FinishGame(this.attemptId);
}

