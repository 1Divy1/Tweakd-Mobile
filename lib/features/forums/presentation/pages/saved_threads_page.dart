import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/saved/bloc.dart';
import '../bloc/saved/event.dart';
import '../bloc/saved/state.dart';
import '../utils/forum_error_mapper.dart';
import '../widgets/shared/forum_error_view.dart';
import '../widgets/shared/forum_section_label.dart';
import '../widgets/shared/forum_sub_top_bar.dart';
import '../widgets/shared/forum_thread_card.dart';
import '../widgets/shared/forum_thread_skeleton.dart';
import '../../../../core/shared/layout/app_layout.dart';

class SavedThreadsPage extends StatefulWidget {
  const SavedThreadsPage({super.key});

  @override
  State<SavedThreadsPage> createState() => _SavedThreadsPageState();
}

class _SavedThreadsPageState extends State<SavedThreadsPage> {
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
      context.read<SavedThreadsBloc>().add(const LoadMoreSavedThreads());
    }
  }

  Future<void> _refresh() async {
    final completer = Completer<void>();
    context.read<SavedThreadsBloc>().add(RefreshSavedThreads(completer));
    await completer.future;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            ForumSubTopBar(title: l10n.forumsSavedTitle),
            Expanded(
              child: BlocConsumer<SavedThreadsBloc, SavedThreadsState>(
                listenWhen: (prev, curr) =>
                    curr.actionError != null &&
                    prev.actionErrorTick != curr.actionErrorTick,
                listener: (context, state) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(
                      content: Text(
                        forumErrorMessage(l10n, state.actionError!),
                      ),
                    ));
                },
                builder: (context, state) {
                  if (state.isLoading) {
                    return const ForumThreadListSkeleton();
                  }
                  if (state.errorCode != null) {
                    return ForumErrorView(
                      message: forumErrorMessage(l10n, state.errorCode!),
                      onRetry: () => context
                          .read<SavedThreadsBloc>()
                          .add(const LoadSavedThreads()),
                    );
                  }
                  return RefreshIndicator(
                    color: AppColors.accent,
                    onRefresh: _refresh,
                    child: state.threads.isEmpty
                        ? _EmptySaved(l10n: l10n)
                        : _SavedList(
                            state: state,
                            scrollController: _scrollController,
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

class _SavedList extends StatelessWidget {
  final SavedThreadsState state;
  final ScrollController scrollController;

  const _SavedList({required this.state, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<SavedThreadsBloc>();

    return ListView(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 8, bottom: 24) + AppLayout.inset(context),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: ForumSectionLabel(label: l10n.forumsSavedHeader),
        ),
        for (final thread in state.threads)
          ForumThreadCard(
            thread: thread,
            onTap: () => context.push('/forums/threads/${thread.id}'),
            onToggleSave: () => bloc.add(UnsaveSavedThread(thread.id)),
          ),
        if (state.isLoadingMore)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.accent,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _EmptySaved extends StatelessWidget {
  final AppLocalizations l10n;

  const _EmptySaved({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: AppLayout.inset(context, maxWidth: AppLayout.narrowWidth),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 80, 32, 24),
          child: Column(
            children: [
              Icon(Icons.bookmark_border_rounded,
                  color: AppColors.muteSoft, size: 44),
              const SizedBox(height: 16),
              Text(
                l10n.forumsSavedEmptyTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.forumsSavedEmptyBody,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.mute,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
