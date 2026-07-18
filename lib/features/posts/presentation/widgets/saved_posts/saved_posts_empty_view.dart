import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../bloc/saved_posts/bloc.dart';
import '../../bloc/saved_posts/event.dart';

/// Empty state for the saved-posts grid. Still wrapped in a [RefreshIndicator]
/// so a user who lands on an empty list can pull to re-check.
class SavedPostsEmptyView extends StatelessWidget {
  const SavedPostsEmptyView({super.key});

  Future<void> _refresh(BuildContext context) async {
    final completer = Completer<void>();
    context.read<SavedPostsBloc>().add(RefreshSavedPosts(completer));
    await completer.future;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return RefreshIndicator(
      color: AppColors.accent,
      onRefresh: () => _refresh(context),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 80, 32, 24),
            child: Column(
              children: [
                const Icon(
                  Icons.bookmark_border_rounded,
                  color: AppColors.muteSoft,
                  size: 44,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.savedPostsEmptyTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.savedPostsEmptyBody,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
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
      ),
    );
  }
}
