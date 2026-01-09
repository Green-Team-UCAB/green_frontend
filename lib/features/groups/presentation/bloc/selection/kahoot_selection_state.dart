import 'package:equatable/equatable.dart';

abstract class KahootSelectionState extends Equatable {
  const KahootSelectionState();

  @override
  List<Object> get props => [];
}

class KahootSelectionInitial extends KahootSelectionState {}

class KahootSelectionLoading extends KahootSelectionState {}

class KahootSelectionLoaded extends KahootSelectionState {
  final List<dynamic> kahoots;

  const KahootSelectionLoaded(this.kahoots);

  @override
  List<Object> get props => [kahoots];
}

class KahootSelectionError extends KahootSelectionState {
  final String message;

  const KahootSelectionError(this.message);

  @override
  List<Object> get props => [message];
}
