import '../../domain/entities/follow_status.dart';

class FollowStatusModel {
  final FollowStatus status;

  const FollowStatusModel({required this.status});

  factory FollowStatusModel.fromJson(Map<String, dynamic> json) {
    return FollowStatusModel(status: _parseStatus(json['status'] as String?));
  }

  FollowStatusEntity toEntity() => FollowStatusEntity(status: status);

  static FollowStatus _parseStatus(String? raw) {
    switch (raw) {
      case 'ACCEPTED':
        return FollowStatus.accepted;
      case 'PENDING':
        return FollowStatus.pending;
      default:
        return FollowStatus.notFollowing;
    }
  }
}
