import 'package:equatable/equatable.dart';

/// A preset reason the user can pick when reporting a post, comment or profile.
/// [id] is echoed back to the backend as `reason_id`.
class ReportReasonEntity extends Equatable {
  final String id;
  final String reason;

  const ReportReasonEntity({required this.id, required this.reason});

  @override
  List<Object?> get props => [id, reason];
}
