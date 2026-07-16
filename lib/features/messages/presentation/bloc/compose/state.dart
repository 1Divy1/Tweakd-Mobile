import 'package:equatable/equatable.dart';

import '../../../domain/entities/message_user.dart';

class ComposeState extends Equatable {
  final bool isLoading;
  final List<MessageUserEntity> users;

  const ComposeState({
    this.isLoading = false,
    this.users = const [],
  });

  ComposeState copyWith({
    bool? isLoading,
    List<MessageUserEntity>? users,
  }) =>
      ComposeState(
        isLoading: isLoading ?? this.isLoading,
        users: users ?? this.users,
      );

  @override
  List<Object?> get props => [isLoading, users];
}
