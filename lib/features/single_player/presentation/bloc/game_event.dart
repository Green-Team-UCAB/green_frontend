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

class NextQuestion extends GameEvent {
  final String attemptId;
  NextQuestion(this.attemptId);
}

class FinishGame extends GameEvent {
  final String attemptId;
  FinishGame(this.attemptId);
}

