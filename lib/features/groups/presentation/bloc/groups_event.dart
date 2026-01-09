part of 'groups_bloc.dart';

abstract class GroupsEvent extends Equatable {
  const GroupsEvent();

  @override
  List<Object> get props => [];
}

class LoadGroupsEvent extends GroupsEvent {}

class CreateGroupEvent extends GroupsEvent {
  final String name;
  final String description;

  const CreateGroupEvent({required this.name, required this.description});
}

class JoinGroupEvent extends GroupsEvent {
  final String token;

  const JoinGroupEvent({required this.token});
}
