import 'package:equatable/equatable.dart';

import '../../../domain/entities/message_user.dart';

class ComposeState extends Equatable {
  final bool isLoading;
  final List<MessageUserEntity> users;

  /// Set once a picked user's conversation is ready — the sheet listens and
  /// navigates to `/messages/{openConversationId}`.
  final String? openConversationId;

  const ComposeState({
    this.isLoading = false,
    this.users = const [],
    this.openConversationId,
  });

  ComposeState copyWith({
    bool? isLoading,
    List<MessageUserEntity>? users,
    String? openConversationId,
  }) =>
      ComposeState(
        isLoading: isLoading ?? this.isLoading,
        users: users ?? this.users,
        openConversationId: openConversationId ?? this.openConversationId,
      );

  @override
  List<Object?> get props => [isLoading, users, openConversationId];
}
