import 'package:equatable/equatable.dart';

import 'message.dart';
import 'message_user.dart';

/// A loaded chat: the other participant plus the message history
/// (oldest first).
class ChatEntity extends Equatable {
  final String conversationId;
  final MessageUserEntity user;
  final List<MessageEntity> messages;

  const ChatEntity({
    required this.conversationId,
    required this.user,
    this.messages = const [],
  });

  @override
  List<Object?> get props => [conversationId, user, messages];
}
