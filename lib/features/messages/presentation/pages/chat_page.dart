import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/message_user.dart';
import '../bloc/chat/bloc.dart';
import '../bloc/chat/event.dart';
import '../bloc/chat/state.dart';
import '../utils/message_time.dart';
import '../utils/messages_error_mapper.dart';
import '../widgets/chat/chat_date_pill.dart';
import '../widgets/chat/chat_input_bar.dart';
import '../widgets/chat/chat_intro_header.dart';
import '../widgets/chat/chat_loading_view.dart';
import '../widgets/chat/chat_top_bar.dart';
import '../widgets/chat/message_bubble.dart';
import '../widgets/chat/shared_post_bubble.dart';
import '../widgets/chat/typing_indicator.dart';
import '../widgets/shared/messages_error_view.dart';
import '../../../../core/shared/layout/app_layout.dart';

/// One open conversation: paged history, live bubbles and the composer.
/// [conversationId] is null when composing to a user with no conversation
/// yet; [peer] is null when the chat was opened by conversation id alone (a
/// push notification tap) and the bloc resolves it from the server, so the
/// header stays bare for that first moment.
class ChatPage extends StatelessWidget {
  final String? conversationId;
  final MessageUserEntity? peer;

  const ChatPage({super.key, required this.conversationId, required this.peer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: BlocConsumer<ChatBloc, ChatState>(
          listenWhen: (previous, current) =>
              current is ChatLoaded && current.actionError != null,
          listener: (context, state) {
            final error = (state as ChatLoaded).actionError!;
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(
                    messagesErrorMessage(AppLocalizations.of(context)!, error),
                  ),
                ),
              );
          },
          builder: (context, state) {
            final loaded = state is ChatLoaded ? state : null;
            final headerUser = loaded?.user ?? peer;
            return Column(
              children: [
                ChatTopBar(
                  user: headerUser,
                  onBack: () => context.pop(),
                  onOpenProfile: headerUser == null
                      ? null
                      : () => context.push(
                          '/users/${headerUser.username}',
                          extra: headerUser.id,
                        ),
                ),
                Expanded(
                  child: switch (state) {
                    ChatInitial() || ChatLoading() => const ChatLoadingView(),
                    ChatError(:final code) => MessagesErrorView(
                      message: messagesErrorMessage(
                        AppLocalizations.of(context)!,
                        code,
                      ),
                      onRetry: () => context.read<ChatBloc>().add(
                        LoadChat(conversationId: conversationId, peer: peer),
                      ),
                    ),
                    ChatLoaded() => _ChatMessagesList(state: state),
                  },
                ),
                ChatInputBar(
                  onSend: (text, cars) => context.read<ChatBloc>().add(
                    SendChatMessage(text, taggedCars: cars),
                  ),
                  onTextChanged: (text) => context.read<ChatBloc>().add(
                    ChatComposerChanged(hasText: text.trim().isNotEmpty),
                  ),
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
/// so it stays pinned to the newest message; scrolling toward the oldest
/// loaded message pulls the next history page.
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

  bool _onScroll(BuildContext context, ScrollNotification notification) {
    // Reversed list: extentAfter shrinks while scrolling up into history.
    if (notification.metrics.extentAfter < 400) {
      context.read<ChatBloc>().add(const LoadOlderMessages());
    }
    return false;
  }

  Future<void> _confirmDelete(BuildContext context, String messageId) async {
    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<ChatBloc>();
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 14),
            ListTile(
              leading: Icon(
                Icons.delete_outline_rounded,
                color: AppColors.accent,
              ),
              title: Text(
                l10n.messagesDeleteMessage,
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Text(
                l10n.messagesDeleteMessageBody,
                style: TextStyle(
                  color: AppColors.mute,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () => Navigator.of(sheetContext).pop(true),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
    if (confirmed == true) {
      bloc.add(DeleteChatMessage(messageId));
    }
  }

  /// Cheap row descriptors (no widget construction) so building the full
  /// list shape stays O(n) even though actual bubble widgets — with their
  /// keys and callbacks — are only ever constructed for rows `itemBuilder`
  /// is asked for (the visible window). This is what keeps a typing
  /// tick from reconstructing every bubble in a long conversation.
  List<_ChatRow> _buildRows(AppLocalizations l10n) {
    final messages = state.messages;
    final rows = <_ChatRow>[
      if (state.isLoadingOlder)
        const _LoadingOlderRow()
      else if (state.olderCursor == null)
        // Fully loaded to the beginning — show the intro header on top.
        const _IntroHeaderRow(),
      if (messages.isEmpty)
        const _EmptyRow()
      else if (state.olderCursor == null)
        _DatePillRow(messageClockTime(messages.first.sentAt)),
    ];

    for (var i = 0; i < messages.length; i++) {
      final message = messages[i];
      final isGroupEnd = _isGroupEnd(messages, i);
      rows.add(
        _MessageRow(
          message: message,
          isGroupEnd: isGroupEnd,
          animate: state.animatedMessageIds.contains(message.id),
        ),
      );
      if (isGroupEnd) {
        rows.add(_TimeLabelRow(message));
      }
    }

    if (state.partnerTyping) {
      rows.add(const _TypingRow());
    }

    return rows;
  }

  Widget _buildRow(BuildContext context, _ChatRow row, AppLocalizations l10n) {
    return switch (row) {
      _LoadingOlderRow() => Padding(
        padding: EdgeInsets.symmetric(vertical: 14),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.accent,
            ),
          ),
        ),
      ),
      _IntroHeaderRow() => ChatIntroHeader(user: state.user),
      _EmptyRow() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            l10n.messagesEmptyChat,
            style: TextStyle(
              color: AppColors.mute,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      _DatePillRow(:final clockTime) => ChatDatePill(
        label: l10n.messagesDatePill(clockTime),
      ),
      _MessageRow(:final message, :final isGroupEnd, :final animate) =>
        message.kind == MessageKind.sharedPost
            ? SharedPostBubble(
                key: ValueKey(message.id),
                message: message,
                animate: animate,
              )
            : MessageBubble(
                key: ValueKey(message.id),
                message: message,
                isGroupEnd: isGroupEnd,
                animate: animate,
                onLongPress: () => _confirmDelete(context, message.id),
                // The about-car route loads any car by id (isOwner=false hides
                // owner-only edit affordances).
                onCarTap: (car) =>
                    context.push('/garage/cars/${car.id}', extra: false),
              ),
      _TimeLabelRow(:final message) => _GroupTimeLabel(
        message: message,
        l10n: l10n,
      ),
      _TypingRow() => const TypingIndicator(key: ValueKey('typing')),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final rows = _buildRows(l10n);

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) => _onScroll(context, notification),
      child: ListView.builder(
        reverse: true,
        padding:
            const EdgeInsets.symmetric(vertical: 10) + AppLayout.inset(context),
        itemCount: rows.length,
        itemBuilder: (context, index) =>
            _buildRow(context, rows[rows.length - 1 - index], l10n),
      ),
    );
  }
}

sealed class _ChatRow {
  const _ChatRow();
}

class _LoadingOlderRow extends _ChatRow {
  const _LoadingOlderRow();
}

class _IntroHeaderRow extends _ChatRow {
  const _IntroHeaderRow();
}

class _EmptyRow extends _ChatRow {
  const _EmptyRow();
}

class _DatePillRow extends _ChatRow {
  final String clockTime;
  const _DatePillRow(this.clockTime);
}

class _MessageRow extends _ChatRow {
  final MessageEntity message;
  final bool isGroupEnd;
  final bool animate;
  const _MessageRow({
    required this.message,
    required this.isGroupEnd,
    required this.animate,
  });
}

class _TimeLabelRow extends _ChatRow {
  final MessageEntity message;
  const _TimeLabelRow(this.message);
}

class _TypingRow extends _ChatRow {
  const _TypingRow();
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
        alignment: message.isMine
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: Text(
          label,
          style: TextStyle(
            color: AppColors.muteSoft,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
