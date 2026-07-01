import 'package:equatable/equatable.dart';

import '../../../domain/entities/report_target.dart';

sealed class ReportEvent extends Equatable {
  const ReportEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the preset reasons for [target]. Dispatched once when the sheet opens.
class LoadReportReasons extends ReportEvent {
  final ReportTarget target;
  const LoadReportReasons(this.target);

  @override
  List<Object?> get props => [target];
}

/// The user tapped a reason radio. Only one reason can be selected.
class SelectReportReason extends ReportEvent {
  final String reasonId;
  const SelectReportReason(this.reasonId);

  @override
  List<Object?> get props => [reasonId];
}

/// The user tapped submit; sends the report for the selected reason.
class SubmitReportPressed extends ReportEvent {
  const SubmitReportPressed();
}
