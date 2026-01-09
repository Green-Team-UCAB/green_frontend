import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/group.dart';
import '../../../domain/repositories/groups_repository.dart';

part 'group_settings_event.dart';
part 'group_settings_state.dart';

class GroupSettingsBloc extends Bloc<GroupSettingsEvent, GroupSettingsState> {
  final GroupsRepository repository;

  GroupSettingsBloc({required this.repository})
    : super(GroupSettingsInitial()) {
    // 1. Manejar Edición de Grupo
    on<UpdateGroupInfoEvent>((event, emit) async {
      emit(GroupSettingsLoading());

      final result = await repository.editGroup(
        event.groupId,
        event.name,
        event.description,
      );

      result.fold(
        (failure) => emit(GroupSettingsError(failure.toString())),
        (updatedGroup) => emit(GroupInfoUpdated(updatedGroup)),
      );
    });

    // 2. Manejar Expulsión de Miembro
    on<KickMemberEvent>((event, emit) async {
      // Nota: Podríamos emitir Loading, pero para una acción rápida en lista
      // a veces es mejor manejar el loading localmente en la UI.
      // Aquí emitimos Loading general por simplicidad.
      emit(GroupSettingsLoading());

      final result = await repository.removeMember(
        event.groupId,
        event.memberId,
      );

      result.fold(
        (failure) => emit(
          GroupSettingsError(
            "No se pudo eliminar al miembro: ${failure.toString()}",
          ),
        ),
        (_) => emit(const MemberKicked("Miembro eliminado correctamente")),
      );
    });

    // 3. Manejar Eliminación de Grupo
    on<DeleteGroupEvent>((event, emit) async {
      emit(GroupSettingsLoading());

      final result = await repository.deleteGroup(event.groupId);

      result.fold(
        (failure) => emit(
          GroupSettingsError(
            "Error al eliminar el grupo: ${failure.toString()}",
          ),
        ),
        (_) => emit(GroupDeleted()),
      );
    });
  }
}
