import 'package:equatable/equatable.dart';

import '../../../domain/entities/message.dart';
import '../../../domain/entities/message_user.dart';
import '../../utils/messages_error_mapper.dart';

sealed class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ChatLoaded extends ChatState {
  final String conversationId;
  final MessageUserEntity user;

  /// Oldest first; the list view renders it reversed.
  final List<MessageEntity> messages;
  final bool partnerTyping;

  /// Ids of messages that appeared after the initial load — the bubbles that
  /// get an entrance animation. Everything from the first load renders still.
  final Set<String> animatedMessageIds;

  const ChatLoaded({
    required this.conversationId,
    required this.user,
    required this.messages,
    this.partnerTyping = false,
    this.animatedMessageIds = const {},
  });

  ChatLoaded copyWith({
    List<MessageEntity>? messages,
    bool? partnerTyping,
    Set<String>? animatedMessageIds,
  }) =>
      ChatLoaded(
        conversationId: conversationId,
        user: user,
        messages: messages ?? this.messages,
        partnerTyping: partnerTyping ?? this.partnerTyping,
        animatedMessageIds: animatedMessageIds ?? this.animatedMessageIds,
      );

  @override
  List<Object?> get props =>
      [conversationId, user, messages, partnerTyping, animatedMessageIds];
}

class ChatError extends ChatState {
  final MessagesErrorCode code;
  const ChatError(this.code);

  @override
  List<Object?> get props => [code];
}
