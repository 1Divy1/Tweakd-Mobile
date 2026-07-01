import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/usecases/usecase.dart';
import '../../../domain/usecases/get_my_reports.dart';
import '../../utils/report_error_mapper.dart';
import 'event.dart';
import 'state.dart';

/// Backs the "My reports" screen: a one-shot load of the reports the current
/// user has filed. Re-dispatch [LoadMyReports] for retry / pull-to-refresh.
@injectable
class MyReportsBloc extends Bloc<MyReportsEvent, MyReportsState> {
  final GetMyReportsUseCase getMyReports;

  MyReportsBloc({required this.getMyReports})
      : super(const MyReportsInitial()) {
    on<LoadMyReports>(_onLoad);
  }

  Future<void> _onLoad(
    LoadMyReports event,
    Emitter<MyReportsState> emit,
  ) async {
    emit(const MyReportsLoading());
    final result = await getMyReports(NoParams());
    result.fold(
      (failure) => emit(MyReportsError(ReportErrorMapper.getCode(failure))),
      (reports) => emit(MyReportsLoaded(reports)),
    );
  }
}
