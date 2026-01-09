import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/group.dart';
import '../../domain/repositories/groups_repository.dart';

part 'groups_event.dart';
part 'groups_state.dart';

class GroupsBloc extends Bloc<GroupsEvent, GroupsState> {
  final GroupsRepository repository;

  GroupsBloc({required this.repository}) : super(GroupsInitial()) {
    // 1. Cargar Grupos
    on<LoadGroupsEvent>((event, emit) async {
      emit(GroupsLoading());
      final result = await repository.getMyGroups();

      result.fold(
        (failure) => emit(GroupsError(message: "Error al cargar grupos")),
        (groups) => emit(GroupsLoaded(groups: groups)),
      );
    });

    // 2. Crear Grupo
    on<CreateGroupEvent>((event, emit) async {
      emit(GroupsLoading());
      final result = await repository.createGroup(
        event.name,
        event.description,
      );

      result.fold(
        (failure) => emit(GroupsError(message: "Error al crear grupo")),
        (group) {
          emit(
            const GroupOperationSuccess(message: "Grupo creado exitosamente"),
          );
          add(LoadGroupsEvent()); // Recargar la lista
        },
      );
    });

    // 3. Unirse a Grupo
    on<JoinGroupEvent>((event, emit) async {
      emit(GroupsLoading());
      final result = await repository.joinGroup(event.token);

      result.fold(
        (failure) =>
            emit(GroupsError(message: "Token inválido o error de conexión")),
        (group) {
          emit(const GroupOperationSuccess(message: "Te has unido al grupo"));
          add(LoadGroupsEvent()); // Recargar la lista
        },
      );
    });
  }
}
