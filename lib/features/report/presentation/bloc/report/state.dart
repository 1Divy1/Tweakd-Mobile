import 'package:equatable/equatable.dart';

import '../../../domain/entities/report_reason.dart';
import '../../utils/report_error_mapper.dart';

/// Lifecycle of the report sheet.
/// - [loadingReasons]/[reasonsError] — fetching the preset reason list.
/// - [ready] — reasons shown, awaiting a pick and submit (also the state after a
///   failed submit; [errorCode] then carries the message to surface inline).
/// - [submitting] — the report POST is in flight.
/// - [success] — the report went through; the sheet shows the confirmation.
enum ReportStatus {
  loadingReasons,
  reasonsError,
  ready,
  submitting,
  success,
}

class ReportState extends Equatable {
  final ReportStatus status;
  final List<ReportReasonEntity> reasons;
  final String? selectedReasonId;

  /// Set after a failed submit so the UI can surface a message; cleared when the
  /// user changes selection or retries.
  final ReportErrorCode? errorCode;

  const ReportState({
    this.status = ReportStatus.loadingReasons,
    this.reasons = const [],
    this.selectedReasonId,
    this.errorCode,
  });

  bool get canSubmit =>
      status == ReportStatus.ready && selectedReasonId != null;

  ReportState copyWith({
    ReportStatus? status,
    List<ReportReasonEntity>? reasons,
    String? selectedReasonId,
    ReportErrorCode? errorCode,
    bool clearError = false,
  }) {
    return ReportState(
      status: status ?? this.status,
      reasons: reasons ?? this.reasons,
      selectedReasonId: selectedReasonId ?? this.selectedReasonId,
      errorCode: clearError ? null : (errorCode ?? this.errorCode),
    );
  }

  @override
  List<Object?> get props => [status, reasons, selectedReasonId, errorCode];
}
