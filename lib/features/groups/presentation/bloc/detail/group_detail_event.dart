part of 'group_detail_bloc.dart';

abstract class GroupDetailEvent extends Equatable {
  const GroupDetailEvent();

  @override
  List<Object> get props => [];
}

class LoadGroupDetailsEvent extends GroupDetailEvent {
  final String groupId;
  const LoadGroupDetailsEvent(this.groupId);
}

class GenerateInviteEvent extends GroupDetailEvent {
  final String groupId;
  const GenerateInviteEvent(this.groupId);
}

// ✅ NUEVO EVENTO H8.6
class AssignQuizEvent extends GroupDetailEvent {
  final String groupId;
  final String quizId;
  final String availableUntil;

  const AssignQuizEvent({
    required this.groupId,
    required this.quizId,
    required this.availableUntil,
  });

  @override
  List<Object> get props => [groupId, quizId, availableUntil];
}
