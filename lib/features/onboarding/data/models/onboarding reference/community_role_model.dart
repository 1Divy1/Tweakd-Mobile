import '../../../domain/entities/onboarding reference/community_role_entity.dart';

class CommunityRoleModel {
  final String id;
  final String name;

  const CommunityRoleModel({required this.id, required this.name});

  factory CommunityRoleModel.fromJson(Map<String, dynamic> json) {
    return CommunityRoleModel(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  CommunityRoleEntity toEntity() => CommunityRoleEntity(id: id, name: name);
}
