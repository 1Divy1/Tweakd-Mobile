import 'package:equatable/equatable.dart';

/// The kind of thing a report was filed against.
enum ReportTargetType { post, comment, profile }

/// Moderation lifecycle of a submitted report. Matches the backend
/// `report_status` enum labels exactly.
enum MyReportStatus { pending, inProgress, resolved, dismissed }

/// One report the current user has filed, as shown on the "My reports" screen.
/// [reason] is null when no preset reason was picked at report time.
class MyReportEntity extends Equatable {
  final ReportTargetType targetType;
  final String targetId;
  final String? reason;
  final MyReportStatus status;
  final DateTime createdAt;

  const MyReportEntity({
    required this.targetType,
    required this.targetId,
    required this.reason,
    required this.status,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [targetType, targetId, reason, status, createdAt];
}
