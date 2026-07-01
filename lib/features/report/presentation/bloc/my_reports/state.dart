import 'package:equatable/equatable.dart';

import '../../../domain/entities/my_report.dart';
import '../../utils/report_error_mapper.dart';

sealed class MyReportsState extends Equatable {
  const MyReportsState();

  @override
  List<Object?> get props => [];
}

class MyReportsInitial extends MyReportsState {
  const MyReportsInitial();
}

class MyReportsLoading extends MyReportsState {
  const MyReportsLoading();
}

class MyReportsLoaded extends MyReportsState {
  final List<MyReportEntity> reports;
  const MyReportsLoaded(this.reports);

  @override
  List<Object?> get props => [reports];
}

class MyReportsError extends MyReportsState {
  final ReportErrorCode code;
  const MyReportsError(this.code);

  @override
  List<Object?> get props => [code];
}
