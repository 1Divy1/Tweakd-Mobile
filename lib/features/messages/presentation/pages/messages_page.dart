import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/message_user.dart';
import '../bloc/inbox/bloc.dart';
import '../bloc/inbox/event.dart';
import '../bloc/inbox/state.dart';
import '../utils/messages_error_mapper.dart';
import '../widgets/inbox/active_now_row.dart';
import '../widgets/inbox/conversation_tile.dart';
import '../widgets/inbox/inbox_search_field.dart';
import '../widgets/inbox/message_requests_tile.dart';
import '../widgets/inbox/messages_empty_view.dart';
import '../widgets/inbox/messages_top_bar.dart';
import '../widgets/inbox/new_message_sheet.dart';
import '../widgets/shared/messages_error_view.dart';
import '../widgets/shared/staggered_entrance.dart';

/// The DM inbox: search, active-now strip, message requests and the
/// conversation list.
class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  Future<void> _openCompose(BuildContext context) async {
    final bloc = context.read<InboxBloc>();
    final conversationId = await showNewMessageSheet(context);
    if (conversationId == null || !context.mounted) return;
    await context.push('/messages/$conversationId');
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
                    InboxInitial() || InboxLoading() => const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
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
/// conversations. Searching collapses the strips and filters the list.
class _InboxList extends StatelessWidget {
  final InboxLoaded state;

  const _InboxList({required this.state});

  Future<void> _refresh(BuildContext context) async {
    final completer = Completer<void>();
    context.read<InboxBloc>().add(RefreshInbox(completer));
    await completer.future;
  }

  Future<void> _openConversation(BuildContext context, String id) async {
    final bloc = context.read<InboxBloc>();
    await context.push('/messages/$id');
    // Re-pull so cleared unread counts and new previews show up.
    bloc.add(const RefreshInbox());
  }

  void _openActiveUser(BuildContext context, MessageUserEntity user) {
    final match = state.inbox.conversations
        .where((c) => c.user.id == user.id)
        .toList();
    if (match.isNotEmpty) _openConversation(context, match.first.id);
  }

  void _comingSoon(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.messagesComingSoon)));
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
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          InboxSearchField(
            onChanged: (query) =>
                context.read<InboxBloc>().add(InboxSearchChanged(query)),
          ),
          if (showStrips) ...[
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
          else
            for (final conversation in conversations)
              StaggeredEntrance(
                index: staggerIndex++,
                child: ConversationTile(
                  conversation: conversation,
                  onTap: () => _openConversation(context, conversation.id),
                ),
              ),
        ],
      ),
    );
  }
}
