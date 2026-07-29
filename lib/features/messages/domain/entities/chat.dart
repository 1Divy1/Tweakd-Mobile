import 'package:equatable/equatable.dart';

import 'message.dart';

/// One keyset page of a conversation's history, already normalized to
/// oldest-first (the wire delivers newest-first).
class MessagesPageEntity extends Equatable {
  final List<MessageEntity> messages;

  /// Echo back as `?cursor=` for the next (older) page; null = no more.
  final String? nextCursor;

  /// Read watermark: every message the viewer sent up to and including this
  /// id has been read by the peer. Null if the peer never read.
  final String? peerLastReadMessageId;

  const MessagesPageEntity({
    this.messages = const [],
    this.nextCursor,
    this.peerLastReadMessageId,
  });

  @override
  List<Object?> get props => [messages, nextCursor, peerLastReadMessageId];
}
