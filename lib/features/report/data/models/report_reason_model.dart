import '../../domain/entities/report_reason.dart';

class ReportReasonModel {
  final String id;
  final String reason;

  const ReportReasonModel({required this.id, required this.reason});

  factory ReportReasonModel.fromJson(Map<String, dynamic> json) {
    return ReportReasonModel(
      id: json['id'] as String,
      reason: json['reason'] as String,
    );
  }

  ReportReasonEntity toEntity() =>
      ReportReasonEntity(id: id, reason: reason);
}
