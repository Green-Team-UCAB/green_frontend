import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/group_quiz_assignment.dart';
import '../../domain/entities/group_leaderboard.dart';
import '../../application/get_group_quizzes_use_case.dart';
import '../../application/get_group_leaderboard_use_case.dart';
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

  AssignQuizEvent({
    required this.groupId,
    required this.quizId,
    required this.availableUntil,
  });
}

// ESTADOS
abstract class GroupDetailState {}

class GroupDetailInitial extends GroupDetailState {}

class GroupDetailLoading extends GroupDetailState {}

class GroupDetailLoaded extends GroupDetailState {
  final List<GroupQuizAssignment> quizzes;
  final List<GroupLeaderboardEntry> leaderboard;

  GroupDetailLoaded({
    required this.quizzes,
    required this.leaderboard,
  });
}

class InvitationGenerated extends GroupDetailState {
  final String link;
  final List<GroupQuizAssignment> quizzes;
  final List<GroupLeaderboardEntry> leaderboard;

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
  final GetGroupQuizzesUseCase getGroupQuizzes;
  final GetGroupLeaderboardUseCase getGroupLeaderboard;
  final GenerateInvitationUseCase generateInvite;
  final AssignQuizUseCase assignQuiz;

  GroupDetailBloc({
    required this.getGroupQuizzes,
    required this.getGroupLeaderboard,
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

    final results = await Future.wait([
      getGroupQuizzes(event.groupId),
      getGroupLeaderboard(event.groupId),
    ]);

    final quizzesResult = results[0] as dynamic;
    final leaderboardResult = results[1] as dynamic;

    String? errorMessage;
    List<GroupQuizAssignment>? quizzes;
    List<GroupLeaderboardEntry>? leaderboard;

    quizzesResult.fold(
      (failure) => errorMessage = failure.message,
      (data) => quizzes = data,
    );

    leaderboardResult.fold(
      (failure) => errorMessage = failure.message,
      (data) => leaderboard = data,
    );

    if (errorMessage != null) {
      emit(GroupDetailError(errorMessage!));
    } else {
      emit(GroupDetailLoaded(
        quizzes: quizzes ?? [],
        leaderboard: leaderboard ?? [],
      ));
    }
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
    final DateTime? untilDate = DateTime.tryParse(event.availableUntil);

    if (untilDate == null) {
      emit(GroupDetailError("Formato de fecha inválido"));
      return;
    }

    final result = await assignQuiz(
      event.groupId,
      event.quizId,
      DateTime.now(),
      untilDate,
    );

    result.fold((failure) => emit(GroupDetailError(failure.message)), (_) {
      emit(QuizAssignedSuccess("Actividad asignada correctamente"));
      add(LoadGroupDetailsEvent(event.groupId));
    });
  }
}
