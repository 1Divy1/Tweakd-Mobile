import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final bool requiresOnboarding;

  const UserEntity({
    required this.id,
    required this.requiresOnboarding,
  });

  @override
  List<Object?> get props => [id, requiresOnboarding];
}
