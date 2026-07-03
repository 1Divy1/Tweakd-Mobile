import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/widgets/app_bottom_nav.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/forum_filter.dart';
import '../bloc/home/bloc.dart';
import '../bloc/home/event.dart';
import '../bloc/home/state.dart';
import '../utils/forum_error_mapper.dart';
import '../widgets/home/forum_shortcuts_row.dart';
import '../widgets/home/forums_empty_view.dart';
import '../widgets/home/forums_top_bar.dart';
import '../widgets/shared/forum_error_view.dart';
import '../widgets/shared/forum_section_label.dart';
import '../widgets/shared/forum_sort_tabs.dart';
import '../widgets/shared/forum_thread_card.dart';
import '../widgets/shared/forum_thread_skeleton.dart';

class ForumsHomePage extends StatefulWidget {
  const ForumsHomePage({super.key});

  @override
  State<ForumsHomePage> createState() => _ForumsHomePageState();
}

class _ForumsHomePageState extends State<ForumsHomePage> {
  final _scrollController = ScrollController();
  bool _isEditingShortcuts = false;

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
      context.read<ForumsHomeBloc>().add(const LoadMoreForumsHome());
    }
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
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            ForumsTopBar(
              onBrowse: () => _pushAndSync('/forums/browse'),
              onNewThread: () => _pushAndSync('/forums/new'),
            ),
            Expanded(
              child: BlocConsumer<ForumsHomeBloc, ForumsHomeState>(
                listenWhen: (prev, curr) =>
                    curr.actionError != null &&
                    prev.actionErrorTick != curr.actionErrorTick,
                listener: (context, state) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(
                      content: Text(forumErrorMessage(
                        AppLocalizations.of(context)!,
                        state.actionError!,
                      )),
                    ));
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
                      onRetry: () => context
                          .read<ForumsHomeBloc>()
                          .add(const LoadForumsHome()),
                    );
                  }
                  return _HomeContent(
                    state: state,
                    scrollController: _scrollController,
                    isEditingShortcuts: _isEditingShortcuts,
                    onToggleEditing: () => setState(
                        () => _isEditingShortcuts = !_isEditingShortcuts),
                    onRefresh: _refresh,
                    onOpenHub: (filter) => _pushAndSync(
                      '/forums/hub',
                      extra: filter,
                    ),
                    onOpenThread: (id) => _pushAndSync('/forums/threads/$id'),
                    onStartThread: () => _pushAndSync('/forums/new'),
                  );
                },
              ),
            ),
            const AppBottomNav(activeTab: AppBottomNavTab.forums),
          ],
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final ForumsHomeState state;
  final ScrollController scrollController;
  final bool isEditingShortcuts;
  final VoidCallback onToggleEditing;
  final Future<void> Function() onRefresh;
  final ValueChanged<ForumFilter> onOpenHub;
  final ValueChanged<String> onOpenThread;
  final VoidCallback onStartThread;

  const _HomeContent({
    required this.state,
    required this.scrollController,
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

    if (state.shortcuts.isEmpty) {
      return RefreshIndicator(
        color: AppColors.accent,
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            ForumsEmptyView(
              suggestedTopics: state.suggestedTopics,
              onPinTopic: (topic) => bloc.add(PinForumTopicShortcut(topic)),
              onStartThread: onStartThread,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.accent,
      onRefresh: onRefresh,
      child: ListView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        children: [
          ForumShortcutsRow(
            shortcuts: state.shortcuts,
            isEditing: isEditingShortcuts,
            onToggleEditing: onToggleEditing,
            onOpen: (shortcut) => onOpenHub(shortcut.filter),
            onRemove: (shortcut) => bloc.add(RemoveForumShortcut(shortcut.id)),
            onMove: (oldIndex, newIndex) =>
                bloc.add(MoveForumShortcut(oldIndex, newIndex)),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ForumSectionLabel(label: l10n.forumsHotInYourForums),
                ),
                ForumSortTabs(
                  active: state.sort,
                  onChanged: (sort) => bloc.add(ChangeForumsHomeSort(sort)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (state.isThreadsLoading)
            const Column(children: [
              ForumThreadCardSkeleton(),
              ForumThreadCardSkeleton(),
              ForumThreadCardSkeleton(),
            ])
          else ...[
            for (final thread in state.threads)
              ForumThreadCard(
                thread: thread,
                onTap: () => onOpenThread(thread.id),
              ),
            if (state.isLoadingMore)
              const Padding(
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
        ],
      ),
    );
  }
}
