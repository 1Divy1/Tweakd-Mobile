import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/widgets/app_pill_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/forum_filter.dart';
import '../bloc/hub/bloc.dart';
import '../bloc/hub/event.dart';
import '../bloc/hub/state.dart';
import '../utils/forum_error_mapper.dart';
import '../utils/forum_format.dart';
import '../widgets/hub/save_shortcut_sheet.dart';
import '../widgets/shared/forum_chips.dart';
import '../widgets/shared/forum_error_view.dart';
import '../widgets/shared/forum_section_label.dart';
import '../widgets/shared/forum_sort_tabs.dart';
import '../widgets/shared/forum_sub_top_bar.dart';
import '../widgets/shared/forum_thread_card.dart';
import '../widgets/shared/forum_thread_skeleton.dart';

class ForumHubPage extends StatefulWidget {
  const ForumHubPage({super.key});

  @override
  State<ForumHubPage> createState() => _ForumHubPageState();
}

class _ForumHubPageState extends State<ForumHubPage> {
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
      context.read<ForumHubBloc>().add(const LoadMoreForumHub());
    }
  }

  Future<void> _openSaveSheet({bool notifyDefault = false}) async {
    final bloc = context.read<ForumHubBloc>();
    final result = await showSaveShortcutSheet(
      context,
      filter: bloc.state.effectiveFilter,
      notifyDefault: notifyDefault,
    );
    if (result != null) {
      bloc.add(SaveForumShortcut(name: result.$1, notify: result.$2));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: BlocConsumer<ForumHubBloc, ForumHubState>(
          listenWhen: (prev, curr) =>
              prev.savedTick != curr.savedTick ||
              (curr.actionError != null &&
                  prev.actionErrorTick != curr.actionErrorTick),
          listener: (context, state) {
            final messenger = ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar();
            if (state.actionError != null) {
              messenger.showSnackBar(SnackBar(
                content: Text(forumErrorMessage(l10n, state.actionError!)),
              ));
            } else {
              messenger.showSnackBar(
                SnackBar(content: Text(l10n.forumsShortcutSaved)),
              );
            }
          },
          builder: (context, state) {
            final filter = state.baseFilter;
            final count =
                filter.model?.threadCount ?? filter.brand?.threadCount;
            final countLabel = count == null
                ? null
                : l10n
                    .forumsThreadsCount(count)
                    .replaceFirst('$count', forumCompactCount(count));
            final subtitle = [
              if (filter.model != null) filter.brand?.name,
              countLabel,
            ].whereType<String>().join(' · ');
            return Column(
              children: [
                ForumSubTopBar(
                  title: filter.title.toUpperCase(),
                  subtitle: subtitle.isEmpty ? null : subtitle,
                  trailing: AppPillButton(
                    icon: Icons.notifications_none_rounded,
                    onTap: () => _openSaveSheet(notifyDefault: true),
                  ),
                ),
                Expanded(
                  child: switch ((state.isLoading, state.errorCode)) {
                    (true, _) => const ForumThreadListSkeleton(),
                    (false, final code?) => ForumErrorView(
                        message: forumErrorMessage(l10n, code),
                        onRetry: () => context
                            .read<ForumHubBloc>()
                            .add(LoadForumHub(filter)),
                      ),
                    _ => _HubContent(
                        state: state,
                        scrollController: _scrollController,
                        onSaveShortcut: () => _openSaveSheet(),
                      ),
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HubContent extends StatelessWidget {
  final ForumHubState state;
  final ScrollController scrollController;
  final VoidCallback onSaveShortcut;

  const _HubContent({
    required this.state,
    required this.scrollController,
    required this.onSaveShortcut,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<ForumHubBloc>();
    final filter = state.baseFilter;
    final isBrandHub = filter.brand != null && filter.model == null;

    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.only(top: 8),
          sliver: SliverToBoxAdapter(
            child: Column(
              children: [
                if (state.effectiveFilter.isRefined) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: _SaveShortcutButton(onTap: onSaveShortcut),
                  ),
                ],
                if (isBrandHub && state.models.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: ForumSectionLabel(label: l10n.forumsModels),
                  ),
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: state.models.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final model = state.models[index];
                        return ForumChoiceChip(
                          label: model.model,
                          selected: false,
                          onTap: () => context.push(
                            '/forums/hub',
                            extra: ForumFilter(
                              brand: filter.brand,
                              model: model,
                              topic: state.refinedTopic,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                if (state.topics.isNotEmpty) ...[
                  // Same chips whether this is a brand hub (level 1) or a model
                  // hub (level 2) — the endpoint takes ?topic= either way.
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: ForumSectionLabel(label: l10n.forumsRefineByTopic),
                  ),
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: state.topics.length + 1,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return ForumChoiceChip(
                            label: l10n.forumsAllTopics,
                            selected: state.refinedTopic == null,
                            onTap: () =>
                                bloc.add(const SelectForumHubTopic(null)),
                          );
                        }
                        final topic = state.topics[index - 1];
                        return ForumChoiceChip(
                          label: topic.name,
                          selected: state.refinedTopic?.id == topic.id,
                          onTap: () => bloc.add(SelectForumHubTopic(topic)),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ForumSectionLabel(
                          label: state.effectiveFilter.isRefined
                              ? l10n.forumsThreadsLabel
                              : l10n.forumsHotIn(filter.title.toUpperCase()),
                        ),
                      ),
                      ForumSortTabs(
                        active: state.sort,
                        onChanged: (sort) => bloc.add(ChangeForumHubSort(sort)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        if (state.isThreadsLoading)
          const SliverToBoxAdapter(
            child: Column(children: [
              ForumThreadCardSkeleton(),
              ForumThreadCardSkeleton(),
              ForumThreadCardSkeleton(),
            ]),
          )
        else if (state.threads.isEmpty)
          SliverToBoxAdapter(child: _EmptyHub(l10n: l10n))
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final thread = state.threads[index];
                return ForumThreadCard(
                  key: ValueKey(thread.id),
                  thread: thread,
                  showExcerpt: state.effectiveFilter.isRefined,
                  hideBrandTag: filter.brand != null,
                  hideModelTag: filter.model != null,
                  onTap: () => context.push('/forums/threads/${thread.id}'),
                  onToggleSave: () => bloc.add(ToggleForumHubSave(thread.id)),
                );
              },
              childCount: state.threads.length,
            ),
          ),
        if (!state.isThreadsLoading &&
            state.threads.isNotEmpty &&
            state.isLoadingMore)
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
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

class _SaveShortcutButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SaveShortcutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.accentSoft.withAlpha(140),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border_rounded,
                color: AppColors.accentHot, size: 18),
            const SizedBox(width: 8),
            Text(
              l10n.forumsSaveShortcut,
              style: TextStyle(
                color: AppColors.accentHot,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyHub extends StatelessWidget {
  final AppLocalizations l10n;

  const _EmptyHub({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 40, 32, 24),
      child: Column(
        children: [
          Text(
            l10n.forumsNoThreadsTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.forumsNoThreadsBody,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.mute,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => context.push('/forums/new'),
            style: TextButton.styleFrom(foregroundColor: AppColors.accent),
            icon: const Icon(Icons.add, size: 18),
            label: Text(
              l10n.forumsStartFirstThread,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
