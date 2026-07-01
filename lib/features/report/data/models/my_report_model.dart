import '../../domain/entities/my_report.dart';

class MyReportModel {
  final String targetType;
  final String targetId;
  final String? reason;
  final String status;
  final String createdAt;

  const MyReportModel({
    required this.targetType,
    required this.targetId,
    required this.reason,
    required this.status,
    required this.createdAt,
  });

  factory MyReportModel.fromJson(Map<String, dynamic> json) {
    return MyReportModel(
      targetType: json['target_type'] as String,
      targetId: json['target_id'] as String,
      reason: json['reason'] as String?,
      status: json['status'] as String,
      createdAt: json['created_at'] as String,
    );
  }

  MyReportEntity toEntity() {
    return MyReportEntity(
      targetType: _targetTypeOf(targetType),
      targetId: targetId,
      reason: reason,
      status: _statusOf(status),
      createdAt: DateTime.parse(createdAt),
    );
  }

  static ReportTargetType _targetTypeOf(String raw) => switch (raw) {
        'post' => ReportTargetType.post,
        'comment' => ReportTargetType.comment,
        'profile' => ReportTargetType.profile,
        // Defensive: an unknown target type falls back to post rather than
        // throwing, so one bad row can't sink the whole list.
        _ => ReportTargetType.post,
      };

  static MyReportStatus _statusOf(String raw) => switch (raw) {
        'pending' => MyReportStatus.pending,
        'in_progress' => MyReportStatus.inProgress,
        'resolved' => MyReportStatus.resolved,
        'dismissed' => MyReportStatus.dismissed,
        _ => MyReportStatus.pending,
      };
}
