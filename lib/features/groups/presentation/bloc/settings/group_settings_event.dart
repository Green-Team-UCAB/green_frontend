part of 'group_settings_bloc.dart';

abstract class GroupSettingsEvent extends Equatable {
  const GroupSettingsEvent();

  @override
  List<Object> get props => [];
}

// Evento H8.5: Editar Nombre/Descripción
class UpdateGroupInfoEvent extends GroupSettingsEvent {
  final String groupId;
  final String name;
  final String description;

  const UpdateGroupInfoEvent({
    required this.groupId,
    required this.name,
    required this.description,
  });

  @override
  List<Object> get props => [groupId, name, description];
}

// Evento H8.4: Eliminar (Expulsar) Miembro
class KickMemberEvent extends GroupSettingsEvent {
  final String groupId;
  final String memberId;

  const KickMemberEvent({required this.groupId, required this.memberId});

  @override
  List<Object> get props => [groupId, memberId];
}

// Evento H8.5: Eliminar Grupo Definitivamente
class DeleteGroupEvent extends GroupSettingsEvent {
  final String groupId;

  const DeleteGroupEvent({required this.groupId});

  @override
  List<Object> get props => [groupId];
}
