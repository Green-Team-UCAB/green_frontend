part of 'groups_bloc.dart';

abstract class GroupsState extends Equatable {
  const GroupsState();

  @override
  List<Object> get props => [];
}

class GroupsInitial extends GroupsState {}

class GroupsLoading extends GroupsState {}

class GroupsLoaded extends GroupsState {
  final List<Group> groups;

  const GroupsLoaded({required this.groups});

  @override
  List<Object> get props => [groups];
}

class GroupsError extends GroupsState {
  final String message;

  const GroupsError({required this.message});

  @override
  List<Object> get props => [message];
}

// Estados "One-shot" para acciones específicas (útil para Snackbars)
class GroupOperationSuccess extends GroupsState {
  final String message;
  const GroupOperationSuccess({required this.message});
}
