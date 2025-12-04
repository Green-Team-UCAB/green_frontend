import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
// CAMBIO: Asegúrate de borrar cualquier referencia a dartz aquí si la hubiera
// fpdart no se necesita importar explícitamente si solo usamos el repositorio,
// pero el repositorio ya devuelve tipos de fpdart.

import '../../domain/entities/report_summary.dart';
import '../../domain/repositories/reports_repository.dart';

part 'reports_event.dart';
part 'reports_state.dart';

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final ReportsRepository repository;

  ReportsBloc({required this.repository}) : super(ReportsInitial()) {
    on<GetMyReportsEvent>(_onGetMyReports);
  }

  Future<void> _onGetMyReports(
    GetMyReportsEvent event,
    Emitter<ReportsState> emit,
  ) async {
    emit(ReportsLoading());

    final result = await repository.getMyResults();

    // fpdart también usa .fold(l, r)
    result.fold(
      (failure) => emit(ReportsError(failure.message)),
      (reports) => emit(ReportsLoaded(reports)),
    );
  }
}
