import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/repositories/groups_repository.dart';

part 'group_detail_event.dart';
part 'group_detail_state.dart';

class GroupDetailBloc extends Bloc<GroupDetailEvent, GroupDetailState> {
  final GroupsRepository repository;

  GroupDetailBloc({required this.repository}) : super(GroupDetailInitial()) {
    on<LoadGroupDetailsEvent>((event, emit) async {
      emit(GroupDetailLoading());

      // Llamamos a los dos endpoints en paralelo para ser eficientes
      final results = await Future.wait([
        repository.getGroupQuizzes(event.groupId),
        repository.getGroupLeaderboard(event.groupId),
      ]);

      final quizzesResult = results[0] as dynamic; // Dartz Either
      final leaderboardResult = results[1] as dynamic; // Dartz Either

      List<dynamic> quizzes = [];
      List<dynamic> leaderboard = [];

      quizzesResult.fold((l) => null, (r) => quizzes = r);
      leaderboardResult.fold((l) => null, (r) => leaderboard = r);

      emit(GroupDetailLoaded(quizzes: quizzes, leaderboard: leaderboard));
    });

    on<GenerateInviteEvent>((event, emit) async {
      final currentState = state;
      if (currentState is GroupDetailLoaded) {
        // No emitimos Loading para no borrar la pantalla, o mostramos un loading overlay
        final result = await repository.generateInvitation(event.groupId);

        result.fold(
          (failure) => null, // Manejar error si quieres con un Toast
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
  }
}
