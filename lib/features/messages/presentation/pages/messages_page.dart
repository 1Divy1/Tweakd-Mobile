import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message_user.dart';
import '../bloc/inbox/bloc.dart';
import '../bloc/inbox/event.dart';
import '../bloc/inbox/state.dart';
import '../utils/messages_error_mapper.dart';
import '../widgets/inbox/active_now_row.dart';
import '../widgets/inbox/conversation_tile.dart';
import '../widgets/inbox/inbox_loading_view.dart';
import '../widgets/inbox/inbox_search_field.dart';
import '../widgets/inbox/message_requests_tile.dart';
import '../widgets/inbox/messages_empty_view.dart';
import '../widgets/inbox/messages_top_bar.dart';
import '../widgets/inbox/new_message_sheet.dart';
import '../widgets/shared/messages_error_view.dart';
import '../widgets/shared/staggered_entrance.dart';

/// The DM inbox: search, active-now strip and the conversation list.
/// Chat routes always carry the peer via `extra` — the messages endpoint has
/// no peer payload, so the header user travels with the navigation.
class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  Future<void> _openCompose(BuildContext context) async {
    final bloc = context.read<InboxBloc>();
    final user = await showNewMessageSheet(context);
    if (user == null || !context.mounted) return;

    // Reuse the existing conversation when one is already loaded; otherwise
    // open a fresh chat — the first message creates the conversation.
    final state = bloc.state;
    ConversationEntity? existing;
    if (state is InboxLoaded) {
      for (final conversation in state.inbox.conversations) {
        if (conversation.user.id == user.id) {
          existing = conversation;
          break;
        }
      }
    }
    if (existing != null) {
      await context.push('/messages/${existing.id}', extra: existing.user);
    } else {
      await context.push('/messages/new', extra: user);
    }
    bloc.add(const RefreshInbox());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            MessagesTopBar(
              onBack: () => context.pop(),
              onCompose: () => _openCompose(context),
            ),
            Expanded(
              child: BlocBuilder<InboxBloc, InboxState>(
                builder: (context, state) {
                  return switch (state) {
                    InboxInitial() || InboxLoading() =>
                      const InboxLoadingView(),
                    InboxError(:final code) => MessagesErrorView(
                        message: messagesErrorMessage(
                          AppLocalizations.of(context)!,
                          code,
                        ),
                        onRetry: () =>
                            context.read<InboxBloc>().add(const LoadInbox()),
                      ),
                    InboxLoaded() => state.inbox.conversations.isEmpty
                        ? MessagesEmptyView(
                            onNewMessage: () => _openCompose(context),
                          )
                        : _InboxList(state: state),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The loaded inbox: pull-to-refresh over search + active-now + requests +
/// conversations, with cursor pagination near the bottom. Searching
/// collapses the strips and filters the loaded list.
class _InboxList extends StatelessWidget {
  final InboxLoaded state;

  const _InboxList({required this.state});

  Future<void> _refresh(BuildContext context) async {
    final completer = Completer<void>();
    context.read<InboxBloc>().add(RefreshInbox(completer));
    await completer.future;
  }

  Future<void> _openConversation(
    BuildContext context,
    ConversationEntity conversation,
  ) async {
    final bloc = context.read<InboxBloc>();
    await context.push(
      '/messages/${conversation.id}',
      extra: conversation.user,
    );
    // Re-pull so cleared unread counts and new previews show up.
    bloc.add(const RefreshInbox());
  }

  void _openActiveUser(BuildContext context, MessageUserEntity user) {
    final match = state.inbox.conversations
        .where((c) => c.user.id == user.id)
        .toList();
    if (match.isNotEmpty) _openConversation(context, match.first);
  }

  Future<void> _confirmHide(
    BuildContext context,
    ConversationEntity conversation,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<InboxBloc>();
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
              leading: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.accent,
              ),
              title: Text(
                l10n.messagesDeleteChat,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Text(
                l10n.messagesDeleteChatBody,
                style: const TextStyle(
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
      bloc.add(HideInboxConversation(conversation.id));
    }
  }

  void _comingSoon(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.messagesComingSoon)));
  }

  bool _onScroll(BuildContext context, ScrollNotification notification) {
    if (notification.metrics.extentAfter < 300) {
      context.read<InboxBloc>().add(const LoadMoreInbox());
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final conversations = state.filteredConversations;
    final showStrips = !state.isSearching;
    var staggerIndex = 0;

    return RefreshIndicator(
      color: AppColors.accent,
      onRefresh: () => _refresh(context),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) => _onScroll(context, notification),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            InboxSearchField(
              onChanged: (query) =>
                  context.read<InboxBloc>().add(InboxSearchChanged(query)),
            ),
            if (showStrips) ...[
              if (state.inbox.activeNow.isNotEmpty)
                StaggeredEntrance(
                  index: staggerIndex++,
                  child: ActiveNowRow(
                    users: state.inbox.activeNow,
                    onUserTap: (user) => _openActiveUser(context, user),
                  ),
                ),
              if (state.inbox.requestsCount > 0)
                StaggeredEntrance(
                  index: staggerIndex++,
                  child: Column(
                    children: [
                      MessageRequestsTile(
                        count: state.inbox.requestsCount,
                        previewNames: state.inbox.requestsPreviewNames,
                        onTap: () => _comingSoon(context),
                      ),
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: AppColors.line2,
                      ),
                    ],
                  ),
                ),
            ],
            if (conversations.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Center(
                  child: Text(
                    l10n.messagesComposeEmpty,
                    style: const TextStyle(
                      color: AppColors.mute,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
            else ...[
              for (var i = 0; i < conversations.length; i++)
                StaggeredEntrance(
                  index: staggerIndex++,
                  child: Column(
                    children: [
                      ConversationTile(
                        conversation: conversations[i],
                        onTap: () =>
                            _openConversation(context, conversations[i]),
                        onLongPress: () =>
                            _confirmHide(context, conversations[i]),
                      ),
                      // Subtle separator between rows, inset past the avatar.
                      if (i != conversations.length - 1)
                        const Padding(
                          padding: EdgeInsets.only(left: 90, right: 20),
                          child: Divider(
                            height: 1,
                            thickness: 1,
                            color: AppColors.line,
                          ),
                        ),
                    ],
                  ),
                ),
              if (state.isLoadingMore)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
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
            ],
          ],
        ),
      ),
    );
  }
}
