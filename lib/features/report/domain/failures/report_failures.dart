import '../../../../core/error/base_failures.dart';

/// The viewer already reported this target (backend 409).
class AlreadyReportedFailure extends Failure {
  const AlreadyReportedFailure() : super(message: 'Already reported.');
}

/// The viewer tried to report their own content/profile (backend 400).
class SelfReportFailure extends Failure {
  const SelfReportFailure() : super(message: 'Cannot report your own content.');
}

/// The chosen reason is not valid for this target type (backend 400).
class InvalidReportReasonFailure extends Failure {
  const InvalidReportReasonFailure() : super(message: 'Invalid report reason.');
}

/// The reported target (post, comment or profile) no longer exists (backend 404).
class ReportTargetNotFoundFailure extends Failure {
  const ReportTargetNotFoundFailure() : super(message: 'Target not found.');
}
