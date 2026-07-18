import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../profile/presentation/widgets/shared/profile_top_bar.dart';
import '../bloc/saved_posts/bloc.dart';
import '../bloc/saved_posts/event.dart';
import '../bloc/saved_posts/state.dart';
import '../utils/post_error_mapper.dart';
import '../widgets/saved_posts/saved_posts_empty_view.dart';
import '../widgets/saved_posts/saved_posts_error_view.dart';
import '../widgets/saved_posts/saved_posts_grid.dart';

/// The "Saved posts" screen: every post the current user has saved, rendered
/// as the same two-column grid as the profile Posts tab. Reached from Settings.
class SavedPostsPage extends StatelessWidget {
  const SavedPostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            ProfileTopBar(title: l10n.savedPostsTitle),
            Expanded(
              child: BlocBuilder<SavedPostsBloc, SavedPostsState>(
                builder: (context, state) {
                  return switch (state) {
                    SavedPostsInitial() ||
                    SavedPostsLoading() =>
                      const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    SavedPostsError(:final code) => SavedPostsErrorView(
                        message: postErrorMessage(l10n, code),
                        onRetry: () => context
                            .read<SavedPostsBloc>()
                            .add(const LoadSavedPosts()),
                      ),
                    SavedPostsLoaded() => state.posts.isEmpty
                        ? const SavedPostsEmptyView()
                        : SavedPostsGridView(state: state),
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
