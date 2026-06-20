import 'package:equatable/equatable.dart';

/// A community role the user can identify with (enthusiast, tuner, …).
class CommunityRoleEntity extends Equatable {
  final String id;
  final String name;

  const CommunityRoleEntity({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}