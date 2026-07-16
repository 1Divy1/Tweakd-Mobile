import 'package:equatable/equatable.dart';

import '../../../domain/entities/message.dart';
import '../../../domain/entities/message_user.dart';
import '../../utils/messages_error_mapper.dart';

const _sentinel = Object();

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
  /// Null until the first message creates the conversation (compose flow).
  final String? conversationId;
  final MessageUserEntity user;

  /// Oldest first; the list view renders it reversed.
  final List<MessageEntity> messages;
  final bool partnerTyping;

  /// Ids of messages that appeared after the initial load — the bubbles that
  /// get an entrance animation. Everything from the first load renders still.
  final Set<String> animatedMessageIds;

  /// Keyset cursor for older history; null = fully loaded.
  final String? olderCursor;
  final bool isLoadingOlder;

  /// Peer's read watermark — the viewer's messages up to and including this
  /// id render "Seen".
  final String? peerLastReadMessageId;

  /// One-shot error for a failed send/delete; the page listener shows a
  /// snackbar and the next state clears it.
  final MessagesErrorCode? actionError;

  const ChatLoaded({
    required this.conversationId,
    required this.user,
    required this.messages,
    this.partnerTyping = false,
    this.animatedMessageIds = const {},
    this.olderCursor,
    this.isLoadingOlder = false,
    this.peerLastReadMessageId,
    this.actionError,
  });

  ChatLoaded copyWith({
    String? conversationId,
    MessageUserEntity? user,
    List<MessageEntity>? messages,
    bool? partnerTyping,
    Set<String>? animatedMessageIds,
    Object? olderCursor = _sentinel,
    bool? isLoadingOlder,
    Object? peerLastReadMessageId = _sentinel,
    Object? actionError = _sentinel,
  }) =>
      ChatLoaded(
        conversationId: conversationId ?? this.conversationId,
        user: user ?? this.user,
        messages: messages ?? this.messages,
        partnerTyping: partnerTyping ?? this.partnerTyping,
        animatedMessageIds: animatedMessageIds ?? this.animatedMessageIds,
        olderCursor: identical(olderCursor, _sentinel)
            ? this.olderCursor
            : olderCursor as String?,
        isLoadingOlder: isLoadingOlder ?? this.isLoadingOlder,
        peerLastReadMessageId: identical(peerLastReadMessageId, _sentinel)
            ? this.peerLastReadMessageId
            : peerLastReadMessageId as String?,
        actionError: identical(actionError, _sentinel)
            ? null // one-shot: cleared unless explicitly re-set
            : actionError as MessagesErrorCode?,
      );

  @override
  List<Object?> get props => [
        conversationId,
        user,
        messages,
        partnerTyping,
        animatedMessageIds,
        olderCursor,
        isLoadingOlder,
        peerLastReadMessageId,
        actionError,
      ];
}

class ChatError extends ChatState {
  final MessagesErrorCode code;
  const ChatError(this.code);

  @override
  List<Object?> get props => [code];
}
