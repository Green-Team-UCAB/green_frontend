import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/group_entity.dart';
import '../../application/get_group_details_use_case.dart';
import '../../application/generate_invitation_use_case.dart';
import '../../application/assign_quiz_use_case.dart';

// EVENTOS
abstract class GroupDetailEvent {}

class LoadGroupDetailsEvent extends GroupDetailEvent {
  final String groupId;
  LoadGroupDetailsEvent(this.groupId);
}

class GenerateInviteEvent extends GroupDetailEvent {
  final String groupId;
  GenerateInviteEvent(this.groupId);
}

class AssignQuizEvent extends GroupDetailEvent {
  final String groupId;
  final String quizId;
  final String availableUntil;
  final String? quizTitle; // Para UI optimista / Mock
  AssignQuizEvent({
    required this.groupId,
    required this.quizId,
    required this.availableUntil,
    this.quizTitle,
  });
}

// ESTADOS
abstract class GroupDetailState {}

class GroupDetailInitial extends GroupDetailState {}

class GroupDetailLoading extends GroupDetailState {}

class GroupDetailLoaded extends GroupDetailState {
  final Map<String, dynamic> data; // Contiene quizzes, leaderboard, etc.
  List<dynamic> get quizzes => data['quizzes'] ?? [];
  List<dynamic> get leaderboard => data['leaderboard'] ?? [];
  GroupEntity? get group => data['group'] is GroupEntity ? data['group'] : null;
  GroupDetailLoaded(this.data);
}

class InvitationGenerated extends GroupDetailState {
  final String link;
  // Mantenemos los datos anteriores para no perder la vista
  final List<dynamic> quizzes;
  final List<dynamic> leaderboard;
  InvitationGenerated(this.link, this.quizzes, this.leaderboard);
}

class QuizAssignedSuccess extends GroupDetailState {
  final String message;
  QuizAssignedSuccess(this.message);
}

class GroupDetailError extends GroupDetailState {
  final String message;
  GroupDetailError(this.message);
}

// BLOC
class GroupDetailBloc extends Bloc<GroupDetailEvent, GroupDetailState> {
  final GetGroupDetailsUseCase getDetails;
  final GenerateInvitationUseCase generateInvite;
  final AssignQuizUseCase assignQuiz;

  GroupDetailBloc({
    required this.getDetails,
    required this.generateInvite,
    required this.assignQuiz,
  }) : super(GroupDetailInitial()) {
    on<LoadGroupDetailsEvent>(_onLoadDetails);
    on<GenerateInviteEvent>(_onGenerateInvite);
    on<AssignQuizEvent>(_onAssignQuiz);
  }

  Future<void> _onLoadDetails(
    LoadGroupDetailsEvent event,
    Emitter<GroupDetailState> emit,
  ) async {
    emit(GroupDetailLoading());
    final result = await getDetails(event.groupId);
    result.fold(
      (failure) => emit(GroupDetailError(failure.message)),
      (data) => emit(GroupDetailLoaded(data)),
    );
  }

  Future<void> _onGenerateInvite(
    GenerateInviteEvent event,
    Emitter<GroupDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is GroupDetailLoaded) {
      final result = await generateInvite(event.groupId);
      result.fold(
        (failure) => emit(GroupDetailError(failure.message)),
        (link) => emit(
          InvitationGenerated(
            link,
            currentState.quizzes,
            currentState.leaderboard,
          ),
        ),
      );
    }
  }

  Future<void> _onAssignQuiz(
    AssignQuizEvent event,
    Emitter<GroupDetailState> emit,
  ) async {
    // Nota: Podríamos emitir loading, pero para feedback rápido usamos snackbar
    final result = await assignQuiz(
      event.groupId,
      event.quizId,
      event.availableUntil,
    );
    result.fold((failure) => emit(GroupDetailError(failure.message)), (_) {
      emit(QuizAssignedSuccess("Actividad asignada correctamente"));
      add(
        LoadGroupDetailsEvent(event.groupId),
      ); // Recargar para ver el quiz nuevo
    });
  }
}
