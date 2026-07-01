import '../../../../core/error/base_failures.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/failures/report_failures.dart';

/// User-facing error situations the report flow can surface. The bloc emits
/// these codes (never strings); the UI maps them to localized copy via
/// [reportErrorMessage].
enum ReportErrorCode {
  alreadyReported,
  selfReport,
  invalidReason,
  targetNotFound,
  network,
  generic,
}

class ReportErrorMapper {
  static ReportErrorCode getCode(Failure failure) {
    if (failure is AlreadyReportedFailure) {
      return ReportErrorCode.alreadyReported;
    }
    if (failure is SelfReportFailure) return ReportErrorCode.selfReport;
    if (failure is InvalidReportReasonFailure) {
      return ReportErrorCode.invalidReason;
    }
    if (failure is ReportTargetNotFoundFailure) {
      return ReportErrorCode.targetNotFound;
    }
    if (failure is NetworkFailure) return ReportErrorCode.network;
    return ReportErrorCode.generic;
  }
}

/// Turns a [ReportErrorCode] into localized copy. Lives in the presentation
/// layer because it needs an [AppLocalizations] from a widget.
String reportErrorMessage(AppLocalizations l10n, ReportErrorCode code) =>
    switch (code) {
      ReportErrorCode.alreadyReported => l10n.reportErrorAlreadyReported,
      ReportErrorCode.selfReport => l10n.reportErrorSelf,
      ReportErrorCode.invalidReason => l10n.reportErrorInvalidReason,
      ReportErrorCode.targetNotFound => l10n.reportErrorNotFound,
      ReportErrorCode.network => l10n.reportErrorNetwork,
      ReportErrorCode.generic => l10n.reportErrorGeneric,
    };
