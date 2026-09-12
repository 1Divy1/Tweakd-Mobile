import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/tagged_item.dart';
import '../bloc/tags/bloc.dart';
import '../bloc/tags/event.dart';
import '../bloc/tags/state.dart';
import '../utils/tag_error_mapper.dart';
import 'tag_item_menu.dart';
import 'tagged_item_card.dart';

/// The Tags tab content on a profile: everything this user (or one of their
/// cars) was tagged in — posts, post comments, forum threads and forum replies,
/// newest tag first.
///
/// The feed is fetched lazily: [TagsBloc] is provided with the profile route
/// but only loads the first time this section is built, so opening a profile
/// doesn't pay for the merged query unless the tab is actually visited.
class TagsSection extends StatefulWidget {
  /// True on your own profile — enables the "⋯" → remove tag action and reads
  /// `/tags/me` instead of `/tags/by-username/{username}`.
  final bool isOwner;

  /// The profile's username. Ignored when [isOwner] is true.
  final String username;

  const TagsSection({
    super.key,
    required this.isOwner,
    required this.username,
  });

  @override
  State<TagsSection> createState() => _TagsSectionState();
}

class _TagsSectionState extends State<TagsSection> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<TagsBloc>();
    if (bloc.state is TagsInitial) {
      bloc.add(LoadTags(username: widget.isOwner ? null : widget.username));
    }
  }

  Future<void> _openMenu(TaggedItemEntity item) async {
    final bloc = context.read<TagsBloc>();
    final action = await showTagItemMenu(context);
    if (action != TagMenuAction.remove || !mounted) return;

    final confirmed = await confirmRemoveTag(context);
    if (confirmed) bloc.add(RemoveTagFromItem(item));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: BlocConsumer<TagsBloc, TagsState>(
        listenWhen: (a, b) =>
            b is TagsLoaded && b.removeError != null && a != b,
        listener: (context, state) {
          if (state is! TagsLoaded || state.removeError == null) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(tagErrorMessage(l10n, state.removeError!))),
          );
          context.read<TagsBloc>().add(const ClearTagRemoveError());
        },
        builder: (context, state) {
          return switch (state) {
            TagsInitial() || TagsLoading() => const _TagsLoadingView(),
            TagsError(:final code) =>
              _TagsMessageView(message: tagErrorMessage(l10n, code)),
            TagsLoaded(:final items) => items.isEmpty
                ? _TagsMessageView(
                    icon: Icons.sell_outlined,
                    message: widget.isOwner
                        ? l10n.tagsEmptyOwner
                        : l10n.tagsEmptyVisitor,
                  )
                : _TagsList(
                    state: state,
                    canRemove: widget.isOwner,
                    onMenu: _openMenu,
                  ),
          };
        },
      ),
    );
  }
}

class _TagsList extends StatelessWidget {
  final TagsLoaded state;
  final bool canRemove;
  final ValueChanged<TaggedItemEntity> onMenu;

  const _TagsList({
    required this.state,
    required this.canRemove,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final item in state.items)
          TaggedItemCard(
            key: ValueKey(item.id),
            item: item,
            canRemove: canRemove,
            isRemoving: state.removingIds.contains(item.id),
            onMenu: () => onMenu(item),
          ),
        if (state.hasMore) ...[
          const SizedBox(height: 2),
          _LoadMoreButton(
            isLoading: state.isLoadingMore,
            label: l10n.tagsLoadMore,
            onTap: () => context.read<TagsBloc>().add(const LoadMoreTags()),
          ),
        ],
      ],
    );
  }
}

class _LoadMoreButton extends StatelessWidget {
  final bool isLoading;
  final String label;
  final VoidCallback onTap;

  const _LoadMoreButton({
    required this.isLoading,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.mute,
                  ),
                )
              : Text(
                  label,
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
        ),
      ),
    );
  }
}

/// Placeholder cards while the first page loads — same silhouette as a real
/// tagged item so the tab doesn't jump when data lands.
class _TagsLoadingView extends StatelessWidget {
  const _TagsLoadingView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < 2; i++)
          Container(
            height: 220,
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: AppColors.line,
              borderRadius: BorderRadius.circular(18),
            ),
          ),
      ],
    );
  }
}

class _TagsMessageView extends StatelessWidget {
  final String message;
  final IconData? icon;

  const _TagsMessageView({required this.message, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 36, color: AppColors.mute),
            const SizedBox(height: 10),
          ],
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.mute,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
