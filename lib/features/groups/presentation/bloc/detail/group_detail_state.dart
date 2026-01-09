part of 'group_detail_bloc.dart';

abstract class GroupDetailState extends Equatable {
  const GroupDetailState();

  @override
  List<Object> get props => [];
}

class GroupDetailInitial extends GroupDetailState {}

class GroupDetailLoading extends GroupDetailState {}

class GroupDetailLoaded extends GroupDetailState {
  final List<dynamic> quizzes;
  final List<dynamic> leaderboard;

  const GroupDetailLoaded({required this.quizzes, required this.leaderboard});

  @override
  List<Object> get props => [quizzes, leaderboard];
}

class GroupDetailError extends GroupDetailState {
  final String message;
  const GroupDetailError(this.message);
}

class InvitationGenerated extends GroupDetailState {
  final String link;
  // Guardamos datos para no perder el fondo
  final List<dynamic> quizzes;
  final List<dynamic> leaderboard;

  const InvitationGenerated({
    required this.link,
    required this.quizzes,
    required this.leaderboard,
  });
}

// ✅ NUEVO ESTADO H8.6
class QuizAssignedSuccess extends GroupDetailState {
  final String message;
  const QuizAssignedSuccess(this.message);
}
