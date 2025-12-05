import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/session_report.dart';
import '../../domain/repositories/reports_repository.dart';

// EVENTOS
abstract class HostReportEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadHostReportEvent extends HostReportEvent {
  final String sessionId;
  LoadHostReportEvent(this.sessionId);

  @override
  List<Object> get props => [sessionId];
}

// ESTADOS
abstract class HostReportState extends Equatable {
  @override
  List<Object> get props => [];
}

class HostReportInitial extends HostReportState {}

class HostReportLoading extends HostReportState {}

class HostReportLoaded extends HostReportState {
  final SessionReport report;
  HostReportLoaded(this.report);

  @override
  List<Object> get props => [report];
}

class HostReportError extends HostReportState {
  final String message;
  HostReportError(this.message);

  @override
  List<Object> get props => [message];
}

// BLOC
class HostReportBloc extends Bloc<HostReportEvent, HostReportState> {
  final ReportsRepository repository;

  HostReportBloc({required this.repository}) : super(HostReportInitial()) {
    on<LoadHostReportEvent>((event, emit) async {
      emit(HostReportLoading());

      final result = await repository.getSessionReport(event.sessionId);

      result.fold(
        (failure) => emit(HostReportError(failure.message)),
        (report) => emit(HostReportLoaded(report)),
      );
    });
  }
}
