import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/repositories/groups_repository.dart';

part 'group_detail_event.dart';
part 'group_detail_state.dart';

class GroupDetailBloc extends Bloc<GroupDetailEvent, GroupDetailState> {
  final GroupsRepository repository;

  GroupDetailBloc({required this.repository}) : super(GroupDetailInitial()) {
    // 1. Cargar Detalles (Quizzes + Ranking)
    on<LoadGroupDetailsEvent>((event, emit) async {
      emit(GroupDetailLoading());

      final results = await Future.wait([
        repository.getGroupQuizzes(event.groupId),
        repository.getGroupLeaderboard(event.groupId),
      ]);

      final quizzesResult = results[0] as dynamic;
      final leaderboardResult = results[1] as dynamic;

      List<dynamic> quizzes = [];
      List<dynamic> leaderboard = [];

      quizzesResult.fold((l) => null, (r) => quizzes = r);
      leaderboardResult.fold((l) => null, (r) => leaderboard = r);

      emit(GroupDetailLoaded(quizzes: quizzes, leaderboard: leaderboard));
    });

    // 2. Generar Invitación
    on<GenerateInviteEvent>((event, emit) async {
      final currentState = state;
      if (currentState is GroupDetailLoaded) {
        final result = await repository.generateInvitation(event.groupId);

        result.fold(
          (failure) => null, // Manejo opcional
          (link) => emit(
            InvitationGenerated(
              link: link,
              quizzes: currentState.quizzes,
              leaderboard: currentState.leaderboard,
            ),
          ),
        );
      }
    });

    // ✅ 3. Asignar Quiz (H8.6)
    on<AssignQuizEvent>((event, emit) async {
      emit(GroupDetailLoading()); // Mostramos carga

      final result = await repository.assignQuiz(
        event.groupId,
        event.quizId,
        event.availableUntil,
      );

      result.fold(
        (failure) =>
            emit(GroupDetailError("Error al asignar: ${failure.toString()}")),
        (_) {
          emit(const QuizAssignedSuccess("Actividad asignada correctamente"));
          // Recargamos inmediatamente para ver el nuevo quiz en la lista
          add(LoadGroupDetailsEvent(event.groupId));
        },
      );
    });
  }
}
