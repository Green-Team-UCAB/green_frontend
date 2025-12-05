import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/report_detail.dart';
import '../../domain/repositories/reports_repository.dart';

// EVENTOS
abstract class ReportDetailEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadReportDetailEvent extends ReportDetailEvent {
  final String reportId;
  LoadReportDetailEvent(this.reportId);
}

// ESTADOS
abstract class ReportDetailState extends Equatable {
  @override
  List<Object> get props => [];
}

class ReportDetailInitial extends ReportDetailState {}

class ReportDetailLoading extends ReportDetailState {}

class ReportDetailLoaded extends ReportDetailState {
  final ReportDetail report;
  ReportDetailLoaded(this.report);
  @override
  List<Object> get props => [report];
}

class ReportDetailError extends ReportDetailState {
  final String message;
  ReportDetailError(this.message);
  @override
  List<Object> get props => [message];
}

// BLOC
class ReportDetailBloc extends Bloc<ReportDetailEvent, ReportDetailState> {
  final ReportsRepository repository;

  ReportDetailBloc({required this.repository}) : super(ReportDetailInitial()) {
    on<LoadReportDetailEvent>((event, emit) async {
      emit(ReportDetailLoading());
      final result = await repository.getReportDetail(event.reportId);
      result.fold(
        (failure) => emit(ReportDetailError(failure.message)),
        (report) => emit(ReportDetailLoaded(report)),
      );
    });
  }
}
