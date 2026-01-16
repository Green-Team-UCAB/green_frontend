import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/update_group_use_case.dart';
import '../../application/kick_member_use_case.dart';
import '../../application/delete_group_use_case.dart';
import '../../application/get_group_members_use_case.dart';
import '../../domain/entities/group_member.dart';

// EVENTOS
abstract class GroupSettingsEvent {}

class UpdateGroupInfoEvent extends GroupSettingsEvent {
  final String groupId;
  final String name;
  final String description;
  UpdateGroupInfoEvent({
    required this.groupId,
    required this.name,
    required this.description,
  });
}

class KickMemberEvent extends GroupSettingsEvent {
  final String groupId;
  final String memberId;
  KickMemberEvent({required this.groupId, required this.memberId});
  @override
  String toString() =>
      'KickMemberEvent(groupId: $groupId, memberId: $memberId)';
}

class DeleteGroupEvent extends GroupSettingsEvent {
  final String groupId;
  DeleteGroupEvent({required this.groupId});
}

class LoadGroupMembersEvent extends GroupSettingsEvent {
  final String groupId;
  LoadGroupMembersEvent({required this.groupId});
}

// ESTADOS
abstract class GroupSettingsState {}

class GroupSettingsInitial extends GroupSettingsState {}

class GroupSettingsLoading extends GroupSettingsState {}

class GroupInfoUpdated extends GroupSettingsState {}

class MemberKicked extends GroupSettingsState {
  final String message;
  MemberKicked(this.message);
}

class GroupDeleted extends GroupSettingsState {}

class GroupMembersLoaded extends GroupSettingsState {
  final List<GroupMember> members;
  GroupMembersLoaded(this.members);
}

class GroupSettingsError extends GroupSettingsState {
  final String message;
  GroupSettingsError(this.message);
}

// BLOC
class GroupSettingsBloc extends Bloc<GroupSettingsEvent, GroupSettingsState> {
  final UpdateGroupUseCase updateGroup;
  final KickMemberUseCase kickMember;
  final DeleteGroupUseCase deleteGroup;
  final GetGroupMembersUseCase getGroupMembers;

  GroupSettingsBloc({
    required this.updateGroup,
    required this.kickMember,
    required this.deleteGroup,
    required this.getGroupMembers,
  }) : super(GroupSettingsInitial()) {
    on<UpdateGroupInfoEvent>((event, emit) async {
      emit(GroupSettingsLoading());
      final result = await updateGroup(
        event.groupId,
        event.name,
        event.description,
      );
      result.fold(
        (f) => emit(GroupSettingsError(f.message)),
        (_) => emit(GroupInfoUpdated()),
      );
    });

    on<KickMemberEvent>((event, emit) async {
      final result = await kickMember(event.groupId, event.memberId);
      result.fold(
        (f) => emit(GroupSettingsError(f.message)),
        (_) => emit(MemberKicked("Miembro expulsado del grupo")),
      );
    });

    on<DeleteGroupEvent>((event, emit) async {
      emit(GroupSettingsLoading());
      final result = await deleteGroup(event.groupId);
      result.fold(
        (f) => emit(GroupSettingsError(f.message)),
        (_) => emit(GroupDeleted()),
      );
    });

    on<LoadGroupMembersEvent>((event, emit) async {
      final result = await getGroupMembers(event.groupId);
      result.fold(
        (f) => emit(GroupSettingsError(f.message)),
        (members) => emit(GroupMembersLoaded(members)),
      );
    });
  }
}
