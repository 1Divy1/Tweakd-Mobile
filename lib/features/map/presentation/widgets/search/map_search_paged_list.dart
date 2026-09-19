import 'package:flutter/material.dart';
import 'package:tweakd/l10n/app_localizations.dart';

import '../../../../../core/shared/layout/app_layout.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../bloc/map_search/state.dart';
import '../../utils/map_error_mapper.dart';
import 'map_search_message.dart';

/// One results tab: a keyset-paged list that asks for the next page as the
/// user nears its end, with the spinner / retry row as its footer.
///
/// The prompt, the empty state and a failed first page replace the list
/// outright; a failed *later* page keeps what's listed and turns the footer
/// into a retry row.
class MapSearchPagedList<T> extends StatelessWidget {
  final MapSearchSection<T> section;
  final bool hasQuery;
  final String emptyMessage;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final VoidCallback onLoadMore;
  final VoidCallback onRetry;

  const MapSearchPagedList({
    super.key,
    required this.section,
    required this.hasQuery,
    required this.emptyMessage,
    required this.itemBuilder,
    required this.onLoadMore,
    required this.onRetry,
  });

  /// How close to the bottom (in pixels) the next page is requested — about
  /// four rows ahead, so it usually lands before the user gets there.
  static const _loadMoreThreshold = 400.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (!hasQuery) {
      return MapSearchMessage(
        icon: Icons.travel_explore_rounded,
        message: l10n.mapSearchPrompt,
      );
    }

    switch (section.status) {
      case MapSearchSectionStatus.idle:
      case MapSearchSectionStatus.loading:
        return Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              color: AppColors.accent,
              strokeWidth: 2.5,
            ),
          ),
        );
      case MapSearchSectionStatus.failure:
        return MapSearchMessage(
          icon: Icons.error_outline_rounded,
          message: mapErrorMessage(
            l10n,
            section.errorCode ?? MapErrorCode.generic,
          ),
          retryLabel: l10n.mapRetry,
          onRetry: onRetry,
        );
      case MapSearchSectionStatus.loaded:
        break;
    }

    if (section.items.isEmpty) {
      return MapSearchMessage(
        icon: Icons.search_off_rounded,
        message: emptyMessage,
      );
    }

    final showFooter =
        section.hasMore || section.isLoadingMore || section.loadMoreFailed;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.extentAfter < _loadMoreThreshold &&
            section.hasMore &&
            !section.isLoadingMore &&
            !section.loadMoreFailed) {
          onLoadMore();
        }
        return false;
      },
      child: ListView.separated(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24) +
            AppLayout.inset(context) +
            EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
        itemCount: section.items.length + (showFooter ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          if (index < section.items.length) {
            return itemBuilder(context, section.items[index]);
          }
          return _Footer(
            failed: section.loadMoreFailed,
            onRetry: onRetry,
          );
        },
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final bool failed;
  final VoidCallback onRetry;

  const _Footer({required this.failed, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (failed) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Text(
              l10n.mapSearchLoadMoreFailed,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.mute, fontSize: 13),
            ),
            TextButton(onPressed: onRetry, child: Text(l10n.mapRetry)),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            color: AppColors.accent,
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }
}
