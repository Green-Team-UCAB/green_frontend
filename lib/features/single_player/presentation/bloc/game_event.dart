import 'package:green_frontend/features/single_player/infraestructure/models/answer_model.dart';

abstract class GameEvent {}

class StartGame extends GameEvent {
  final String kahootId;
  StartGame(this.kahootId);
}

class SubmitAnswerEvent extends GameEvent {
  final String attemptId;
  final AnswerModel answer;
  SubmitAnswerEvent(this.attemptId, this.answer);
}

class FinishGame extends GameEvent {
  final String attemptId;
  FinishGame(this.attemptId);
}
