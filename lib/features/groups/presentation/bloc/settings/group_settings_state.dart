part of 'group_settings_bloc.dart';

abstract class GroupSettingsState extends Equatable {
  const GroupSettingsState();

  @override
  List<Object> get props => [];
}

class GroupSettingsInitial extends GroupSettingsState {}

class GroupSettingsLoading extends GroupSettingsState {}

// Éxito al editar info: Devolvemos el grupo nuevo para actualizar la vista anterior
class GroupInfoUpdated extends GroupSettingsState {
  final Group group;
  const GroupInfoUpdated(this.group);
}

// Éxito al expulsar a alguien
class MemberKicked extends GroupSettingsState {
  final String message;
  const MemberKicked(this.message);
}

// Éxito al eliminar el grupo (Debemos sacar al usuario de la pantalla)
class GroupDeleted extends GroupSettingsState {}

class GroupSettingsError extends GroupSettingsState {
  final String message;
  const GroupSettingsError(this.message);
}
