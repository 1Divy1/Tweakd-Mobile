class UserEntity {
  final String id;
  final String name;
  final String email;
  final String? profilePictureUrl;
  final String? username;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.profilePictureUrl,
    this.username,
  });

  bool get requiresOnboarding => username == null || username!.isEmpty;
}