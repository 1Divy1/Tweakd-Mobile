import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/message.dart';
import '../bloc/chat/bloc.dart';
import '../bloc/chat/event.dart';
import '../bloc/chat/state.dart';
import '../utils/message_time.dart';
import '../utils/messages_error_mapper.dart';
import '../widgets/chat/chat_date_pill.dart';
import '../widgets/chat/chat_input_bar.dart';
import '../widgets/chat/chat_intro_header.dart';
import '../widgets/chat/chat_top_bar.dart';
import '../widgets/chat/message_bubble.dart';
import '../widgets/chat/shared_post_bubble.dart';
import '../widgets/chat/typing_indicator.dart';
import '../widgets/shared/messages_error_view.dart';

/// One open conversation: history, live bubbles and the composer.
class ChatPage extends StatelessWidget {
  final String conversationId;

  const ChatPage({super.key, required this.conversationId});

  void _comingSoon(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.messagesComingSoon)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            final loaded = state is ChatLoaded ? state : null;
            return Column(
              children: [
                ChatTopBar(
                  user: loaded?.user,
                  onBack: () => context.pop(),
                ),
                Expanded(
                  child: switch (state) {
                    ChatInitial() || ChatLoading() => const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    ChatError(:final code) => MessagesErrorView(
                        message: messagesErrorMessage(
                          AppLocalizations.of(context)!,
                          code,
                        ),
                        onRetry: () => context
                            .read<ChatBloc>()
                            .add(LoadChat(conversationId)),
                      ),
                    ChatLoaded() => _ChatMessagesList(state: state),
                  },
                ),
                ChatInputBar(
                  onSend: (text) =>
                      context.read<ChatBloc>().add(SendChatMessage(text)),
                  onAttach: () => _comingSoon(context),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// The scrollable transcript: intro header, date pill, grouped bubbles with
/// time / seen labels and the typing indicator. Rendered as a reversed list
/// so it stays pinned to the newest message.
class _ChatMessagesList extends StatelessWidget {
  final ChatLoaded state;

  const _ChatMessagesList({required this.state});

  /// Last bubble of a sender run (next message is from the other side or
  /// clearly later) — gets the tail corner and the time label.
  bool _isGroupEnd(List<MessageEntity> messages, int index) {
    if (index == messages.length - 1) return true;
    final current = messages[index];
    final next = messages[index + 1];
    return next.isMine != current.isMine ||
        next.sentAt.difference(current.sentAt).inMinutes >= 5;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final messages = state.messages;

    final items = <Widget>[
      ChatIntroHeader(user: state.user),
      if (messages.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: Text(
              l10n.messagesEmptyChat,
              style: const TextStyle(
                color: AppColors.mute,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        )
      else
        ChatDatePill(
          label: l10n.messagesDatePill(messageClockTime(messages.first.sentAt)),
        ),
    ];

    for (var i = 0; i < messages.length; i++) {
      final message = messages[i];
      final animate = state.animatedMessageIds.contains(message.id);

      items.add(
        message.kind == MessageKind.sharedPost
            ? SharedPostBubble(
                key: ValueKey(message.id),
                message: message,
                animate: animate,
              )
            : MessageBubble(
                key: ValueKey(message.id),
                message: message,
                isGroupEnd: _isGroupEnd(messages, i),
                animate: animate,
              ),
      );

      if (_isGroupEnd(messages, i)) {
        items.add(_GroupTimeLabel(message: message, l10n: l10n));
      }
    }

    if (state.partnerTyping) {
      items.add(const TypingIndicator(key: ValueKey('typing')));
    }

    return ListView(
      reverse: true,
      padding: const EdgeInsets.symmetric(vertical: 10),
      children: items.reversed.toList(),
    );
  }
}

/// "8:12" under the other user's bubble group; "8:15 · Seen" under the
/// viewer's when the read receipt arrived.
class _GroupTimeLabel extends StatelessWidget {
  final MessageEntity message;
  final AppLocalizations l10n;

  const _GroupTimeLabel({required this.message, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final time = messageClockTime(message.sentAt);
    final label = message.isMine && message.isSeen
        ? '$time · ${l10n.messagesSeen}'
        : time;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 2, 24, 10),
      child: Align(
        alignment:
            message.isMine ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.muteSoft,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
