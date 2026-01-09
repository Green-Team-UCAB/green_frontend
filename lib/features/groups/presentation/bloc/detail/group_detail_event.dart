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
