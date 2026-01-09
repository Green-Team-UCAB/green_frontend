import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/group_entity.dart';
import '../../application/get_my_groups_use_case.dart';
import '../../application/create_group_use_case.dart';
import '../../application/join_group_use_case.dart';

// EVENTOS
abstract class GroupsEvent {}

class LoadGroupsEvent extends GroupsEvent {}

class CreateGroupEvent extends GroupsEvent {
  final String name;
  final String description;
  CreateGroupEvent({required this.name, required this.description});
}

class JoinGroupEvent extends GroupsEvent {
  final String token;
  JoinGroupEvent({required this.token});
}

// ESTADOS
abstract class GroupsState {}

class GroupsInitial extends GroupsState {}

class GroupsLoading extends GroupsState {}

class GroupsLoaded extends GroupsState {
  final List<GroupEntity> groups;
  GroupsLoaded(this.groups);
}

class GroupOperationSuccess extends GroupsState {
  final String message;
  GroupOperationSuccess(this.message);
}

class GroupsError extends GroupsState {
  final String message;
  GroupsError(this.message);
}

// BLOC
class GroupsBloc extends Bloc<GroupsEvent, GroupsState> {
  final GetMyGroupsUseCase getMyGroups;
  final CreateGroupUseCase createGroup;
  final JoinGroupUseCase joinGroup;

  GroupsBloc({
    required this.getMyGroups,
    required this.createGroup,
    required this.joinGroup,
  }) : super(GroupsInitial()) {
    on<LoadGroupsEvent>(_onLoadGroups);
    on<CreateGroupEvent>(_onCreateGroup);
    on<JoinGroupEvent>(_onJoinGroup);
  }

  Future<void> _onLoadGroups(
    LoadGroupsEvent event,
    Emitter<GroupsState> emit,
  ) async {
    emit(GroupsLoading());
    final result = await getMyGroups();
    result.fold(
      (failure) => emit(GroupsError(failure.message)),
      (groups) => emit(GroupsLoaded(groups)),
    );
  }

  Future<void> _onCreateGroup(
    CreateGroupEvent event,
    Emitter<GroupsState> emit,
  ) async {
    emit(GroupsLoading());
    final result = await createGroup(event.name, event.description);
    result.fold((failure) => emit(GroupsError(failure.message)), (group) {
      emit(GroupOperationSuccess("Grupo '${group.name}' creado exitosamente"));
      add(LoadGroupsEvent()); // Recargar lista
    });
  }

  Future<void> _onJoinGroup(
    JoinGroupEvent event,
    Emitter<GroupsState> emit,
  ) async {
    emit(GroupsLoading());
    final result = await joinGroup(event.token);
    result.fold((failure) => emit(GroupsError(failure.message)), (group) {
      emit(GroupOperationSuccess("Te uniste a '${group.name}'"));
      add(LoadGroupsEvent()); // Recargar lista
    });
  }
}
