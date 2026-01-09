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

// Estado especial para cuando se genera el link (para mostrarlo en un Dialog)
class InvitationGenerated extends GroupDetailState {
  final String link;
  // Guardamos los datos anteriores para no perder la vista de fondo
  final List<dynamic> quizzes;
  final List<dynamic> leaderboard;

  const InvitationGenerated({
    required this.link,
    required this.quizzes,
    required this.leaderboard,
  });
}
