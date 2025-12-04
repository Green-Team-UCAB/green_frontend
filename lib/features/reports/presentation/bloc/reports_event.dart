part of 'reports_bloc.dart';

abstract class ReportsEvent extends Equatable {
  const ReportsEvent();

  @override
  List<Object> get props => [];
}

class GetMyReportsEvent extends ReportsEvent {}
