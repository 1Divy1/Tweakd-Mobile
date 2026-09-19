import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/shared/utils/scroll_to_top.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/forum_filter.dart';
import '../../bloc/home/bloc.dart';
import '../../bloc/home/event.dart';
import '../../bloc/home/state.dart';
import '../../utils/forum_error_mapper.dart';
import '../shared/forum_error_view.dart';
import '../shared/forum_section_label.dart';
import '../shared/forum_sort_tabs.dart';
import '../shared/forum_thread_card.dart';
import '../shared/forum_thread_skeleton.dart';
import 'forum_shortcuts_row.dart';
import 'forums_empty_view.dart';
import '../../../../../core/shared/layout/app_layout.dart';

/// The forums home — pinned shortcuts over the hot threads in them — as the
/// Forums segment of the home tab. The chrome around it (top bar, segment
/// switch, bottom nav) belongs to `FeedPage`; browse and saved sit on the
/// segment bar as `ForumsHomeActions`, and new threads start from the bottom
/// nav's create button or the empty state's call to action.
class ForumsHomeView extends StatefulWidget {
  /// Fires when the home tab is tapped while already on it: scroll back to
  /// the top and refresh.
  final Listenable? reselected;

  const ForumsHomeView({super.key, this.reselected});

  @override
  State<ForumsHomeView> createState() => _ForumsHomeViewState();
}

class _ForumsHomeViewState extends State<ForumsHomeView> {
  final _scrollController = ScrollController();
  final _refreshKey = GlobalKey<RefreshIndicatorState>();
  bool _isEditingShortcuts = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    widget.reselected?.addListener(_scrollToTopAndRefresh);
  }

  @override
  void didUpdateWidget(ForumsHomeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reselected != widget.reselected) {
      oldWidget.reselected?.removeListener(_scrollToTopAndRefresh);
      widget.reselected?.addListener(_scrollToTopAndRefresh);
    }
  }

  @override
  void dispose() {
    widget.reselected?.removeListener(_scrollToTopAndRefresh);
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 600) {
      context.read<ForumsHomeBloc>().add(const LoadMoreForumsHome());
    }
  }

  Future<void> _scrollToTopAndRefresh() async {
    await scrollToTop(_scrollController);
    if (mounted) _refreshKey.currentState?.show();
  }

  Future<void> _refresh() async {
    final completer = Completer<void>();
    context.read<ForumsHomeBloc>().add(RefreshForumsHome(completer));
    await completer.future;
  }

  /// Navigates away and re-syncs on return (a shortcut may have been saved,
  /// threads created, …).
  Future<void> _pushAndSync(String location, {Object? extra}) async {
    final bloc = context.read<ForumsHomeBloc>();
    await context.push(location, extra: extra);
    bloc.add(const RefreshForumsHome());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ForumsHomeBloc, ForumsHomeState>(
      listenWhen: (prev, curr) =>
          curr.actionError != null &&
          prev.actionErrorTick != curr.actionErrorTick,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                forumErrorMessage(
                  AppLocalizations.of(context)!,
                  state.actionError!,
                ),
              ),
            ),
          );
      },
      builder: (context, state) {
        if (state.isLoading) {
          return const ForumThreadListSkeleton();
        }
        if (state.errorCode != null) {
          return ForumErrorView(
            message: forumErrorMessage(
              AppLocalizations.of(context)!,
              state.errorCode!,
            ),
            onRetry: () =>
                context.read<ForumsHomeBloc>().add(const LoadForumsHome()),
          );
        }
        return _HomeContent(
          state: state,
          scrollController: _scrollController,
          refreshKey: _refreshKey,
          isEditingShortcuts: _isEditingShortcuts,
          onToggleEditing: () =>
              setState(() => _isEditingShortcuts = !_isEditingShortcuts),
          onRefresh: _refresh,
          onOpenHub: (filter) => _pushAndSync('/forums/hub', extra: filter),
          onOpenThread: (id) => _pushAndSync('/forums/threads/$id'),
          onStartThread: () => _pushAndSync('/forums/new'),
        );
      },
    );
  }
}

class _HomeContent extends StatelessWidget {
  final ForumsHomeState state;
  final ScrollController scrollController;
  final Key refreshKey;
  final bool isEditingShortcuts;
  final VoidCallback onToggleEditing;
  final Future<void> Function() onRefresh;
  final ValueChanged<ForumFilter> onOpenHub;
  final ValueChanged<String> onOpenThread;
  final VoidCallback onStartThread;

  const _HomeContent({
    required this.state,
    required this.scrollController,
    required this.refreshKey,
    required this.isEditingShortcuts,
    required this.onToggleEditing,
    required this.onRefresh,
    required this.onOpenHub,
    required this.onOpenThread,
    required this.onStartThread,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<ForumsHomeBloc>();

    // An empty paddock keeps the same scroll view: the explainer heads the
    // global hot list, so a new user lands on live threads, not a blank page.
    return RefreshIndicator(
      key: refreshKey,
      color: AppColors.accent,
      onRefresh: onRefresh,
      child: CustomScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverContentFrame(
            sliver: SliverMainAxisGroup(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.only(top: 8),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      children: [
                        if (state.shortcuts.isEmpty)
                          ForumsEmptyView(
                            hasThreads:
                                state.threads.isNotEmpty ||
                                state.isThreadsLoading,
                            onStartThread: onStartThread,
                          )
                        else ...[
                          ForumShortcutsRow(
                            shortcuts: state.shortcuts,
                            isEditing: isEditingShortcuts,
                            onToggleEditing: onToggleEditing,
                            onOpen: (shortcut) => onOpenHub(shortcut.filter),
                            onRemove: (shortcut) =>
                                bloc.add(RemoveForumShortcut(shortcut.id)),
                            onMove: (oldIndex, newIndex) =>
                                bloc.add(MoveForumShortcut(oldIndex, newIndex)),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ForumSectionLabel(
                                    label: l10n.forumsHotInYourForums,
                                  ),
                                ),
                                ForumSortTabs(
                                  active: state.sort,
                                  onChanged: (sort) =>
                                      bloc.add(ChangeForumsHomeSort(sort)),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
                if (state.isThreadsLoading)
                  const SliverToBoxAdapter(
                    child: Column(
                      children: [
                        ForumThreadCardSkeleton(),
                        ForumThreadCardSkeleton(),
                        ForumThreadCardSkeleton(),
                      ],
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final thread = state.threads[index];
                      return ForumThreadCard(
                        key: ValueKey(thread.id),
                        thread: thread,
                        onTap: () => onOpenThread(thread.id),
                        onToggleSave: () =>
                            bloc.add(ToggleForumSaveInFeed(thread.id)),
                      );
                    }, childCount: state.threads.length),
                  ),
                if (!state.isThreadsLoading && state.isLoadingMore)
                  SliverToBoxAdapter(
                    child: Padding(
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
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
