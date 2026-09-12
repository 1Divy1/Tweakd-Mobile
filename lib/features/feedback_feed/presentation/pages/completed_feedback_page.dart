import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/widgets/app_pill_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/completed/bloc.dart';
import '../bloc/completed/event.dart';
import '../bloc/completed/state.dart';
import '../utils/feedback_feed_error_mapper.dart';
import '../widgets/completed/completed_feedback_card.dart';
import '../widgets/shared/feedback_feed_views.dart';

/// The shipped requests, newest first. Read-only: the cards show what was asked
/// and what the team answered, with the final net score as plain text.
class CompletedFeedbackPage extends StatefulWidget {
  const CompletedFeedbackPage({super.key});

  @override
  State<CompletedFeedbackPage> createState() => _CompletedFeedbackPageState();
}

class _CompletedFeedbackPageState extends State<CompletedFeedbackPage> {
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
      context.read<CompletedFeedbackBloc>().add(
            const LoadMoreCompletedFeedback(),
          );
    }
  }

  Future<void> _refresh() async {
    final completer = Completer<void>();
    context.read<CompletedFeedbackBloc>().add(
          RefreshCompletedFeedback(completer),
        );
    await completer.future;
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
            _TopBar(title: l10n.feedbackFeedCompletedTitle),
            Expanded(
              child: BlocBuilder<CompletedFeedbackBloc, CompletedFeedbackState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const FeedbackFeedLoadingView();
                  }

                  if (state.errorCode != null && state.messages.isEmpty) {
                    return FeedbackFeedErrorView(
                      message: feedbackFeedErrorMessage(l10n, state.errorCode!),
                      onRetry: () => context
                          .read<CompletedFeedbackBloc>()
                          .add(const LoadCompletedFeedback()),
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.accent,
                    onRefresh: _refresh,
                    child: state.messages.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              const SizedBox(height: 80),
                              FeedbackFeedEmptyView(
                                icon: Icons.check_circle_outline_rounded,
                                title: l10n.feedbackFeedCompletedEmptyTitle,
                                body: l10n.feedbackFeedCompletedEmptyBody,
                              ),
                            ],
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(top: 4, bottom: 24),
                            itemCount: state.messages.length + 1,
                            itemBuilder: (context, index) {
                              if (index == state.messages.length) {
                                return FeedbackFeedListFooter(
                                  isLoadingMore: state.isLoadingMore,
                                );
                              }
                              final message = state.messages[index];
                              return CompletedFeedbackCard(
                                key: ValueKey(message.id),
                                message: message,
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

/// Back button plus a left-aligned title, as in the design.
class _TopBar extends StatelessWidget {
  final String title;

  const _TopBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Row(
        children: [
          AppPillButton(
            icon: Icons.chevron_left_rounded,
            onTap: () => context.pop(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
