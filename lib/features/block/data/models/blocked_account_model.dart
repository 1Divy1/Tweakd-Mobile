import '../../domain/entities/blocked_account.dart';

class BlockedAccountModel {
  final String id;
  final String username;
  final String? name;
  final String? avatarUrl;
  final DateTime? blockedAt;

  const BlockedAccountModel({
    required this.id,
    required this.username,
    this.name,
    this.avatarUrl,
    this.blockedAt,
  });

  factory BlockedAccountModel.fromJson(Map<String, dynamic> json) {
    final blockedAt = json['blocked_at'] as String?;
    return BlockedAccountModel(
      id: json['id'] as String,
      username: json['username'] as String,
      name: json['name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      blockedAt: blockedAt == null ? null : DateTime.tryParse(blockedAt),
    );
  }

  BlockedAccountEntity toEntity() => BlockedAccountEntity(
        id: id,
        username: username,
        name: name,
        avatarUrl: avatarUrl,
        blockedAt: blockedAt,
      );
}
