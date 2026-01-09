import 'package:equatable/equatable.dart';

abstract class KahootSelectionEvent extends Equatable {
  const KahootSelectionEvent();

  @override
  List<Object> get props => [];
}

class LoadMyKahootsEvent extends KahootSelectionEvent {}
