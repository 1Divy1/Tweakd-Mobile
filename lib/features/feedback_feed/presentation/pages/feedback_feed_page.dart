import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/board/bloc.dart';
import '../bloc/board/event.dart';
import '../bloc/board/state.dart';
import '../utils/feedback_feed_error_mapper.dart';
import '../widgets/board/completed_requests_banner.dart';
import '../widgets/board/delete_feedback_dialog.dart';
import '../widgets/board/feedback_feed_top_bar.dart';
import '../widgets/board/feedback_message_card.dart';
import '../widgets/board/feedback_sort_tabs.dart';
import '../widgets/shared/feedback_feed_views.dart';
import '../../../../core/shared/layout/app_layout.dart';

/// The community feedback board, pushed from the megaphone on your own profile
/// (and from status-change notifications). Sorting and the completed-requests
/// link stay pinned above the list; only the list itself swaps between
/// loading / error / empty / loaded.
class FeedbackFeedPage extends StatefulWidget {
  const FeedbackFeedPage({super.key});

  @override
  State<FeedbackFeedPage> createState() => _FeedbackFeedPageState();
}

class _FeedbackFeedPageState extends State<FeedbackFeedPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 600) {
      context.read<FeedbackBoardBloc>().add(const LoadMoreFeedbackBoard());
    }
  }

  Future<void> _refresh() async {
    // A Completer (not a state listener) drives the indicator: a refresh that
    // returns identical data emits no new state, so waiting on the stream
    // would hang the spinner forever.
    final completer = Completer<void>();
    context.read<FeedbackBoardBloc>().add(RefreshFeedbackBoard(completer));
    await completer.future;
  }

  /// Opens the composer and pulls the new message in on the way back.
  Future<void> _compose() async {
    final bloc = context.read<FeedbackBoardBloc>();
    final posted = await context.push<bool>('/feedback-feed/new');
    if (posted == true) bloc.add(const RefreshFeedbackBoard());
  }

  /// Completed messages are excluded from this list, so nothing here needs to
  /// change on the way back.
  void _openCompleted() => context.push('/feedback-feed/completed');

  Future<void> _confirmDelete(String messageId) async {
    final bloc = context.read<FeedbackBoardBloc>();
    final confirmed = await showDeleteFeedbackDialog(context);
    if (confirmed) bloc.add(DeleteFeedbackMessage(messageId));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            FeedbackFeedTopBar(onCompose: _compose),
            BlocBuilder<FeedbackBoardBloc, FeedbackBoardState>(
              buildWhen: (prev, curr) => prev.sort != curr.sort,
              builder: (context, state) => FeedbackSortTabs(
                active: state.sort,
                onChanged: (sort) => context
                    .read<FeedbackBoardBloc>()
                    .add(ChangeFeedbackSort(sort)),
              ),
            ),
            CompletedRequestsBanner(onTap: _openCompleted),
            Expanded(
              child: BlocConsumer<FeedbackBoardBloc, FeedbackBoardState>(
                // Vote/delete failures are one-shot snackbars, keyed on the
                // tick so the same error twice still shows.
                listenWhen: (prev, curr) =>
                    curr.actionError != null &&
                    prev.actionErrorTick != curr.actionErrorTick,
                listener: (context, state) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(
                      content: Text(
                        feedbackFeedErrorMessage(l10n, state.actionError!),
                      ),
                    ));

                  // A delete refused with 409 means the card's status is stale,
                  // so pull the real one in.
                  if (state.actionError == FeedbackFeedErrorCode.locked) {
                    context
                        .read<FeedbackBoardBloc>()
                        .add(const RefreshFeedbackBoard());
                  }
                },
                builder: (context, state) {
                  if (state.isLoading) {
                    return const FeedbackFeedLoadingView();
                  }

                  if (state.errorCode != null && state.messages.isEmpty) {
                    return FeedbackFeedErrorView(
                      message: feedbackFeedErrorMessage(l10n, state.errorCode!),
                      onRetry: () => context
                          .read<FeedbackBoardBloc>()
                          .add(const LoadFeedbackBoard()),
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.accent,
                    onRefresh: _refresh,
                    child: state.messages.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: AppLayout.inset(context),
                            children: [
                              const SizedBox(height: 80),
                              FeedbackFeedEmptyView(
                                icon: Icons.forum_outlined,
                                title: l10n.feedbackFeedEmptyTitle,
                                body: l10n.feedbackFeedEmptyBody,
                              ),
                            ],
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            // No bottom nav any more, so clear the home
                            // indicator while still scrolling under it.
                            padding: EdgeInsets.only(
                              top: 2,
                              bottom: 16 + MediaQuery.paddingOf(context).bottom,
                            ) + AppLayout.inset(context),
                            itemCount: state.messages.length + 1,
                            itemBuilder: (context, index) {
                              if (index == state.messages.length) {
                                return FeedbackFeedListFooter(
                                  isLoadingMore: state.isLoadingMore,
                                );
                              }
                              final message = state.messages[index];
                              return FeedbackMessageCard(
                                key: ValueKey(message.id),
                                message: message,
                                onVote: (value) =>
                                    context.read<FeedbackBoardBloc>().add(
                                          VoteOnFeedbackMessage(
                                            messageId: message.id,
                                            value: value,
                                          ),
                                        ),
                                onDelete: () => _confirmDelete(message.id),
                              );
                            },
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
