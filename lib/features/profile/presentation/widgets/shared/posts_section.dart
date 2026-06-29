import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../posts/presentation/bloc/profile_posts/bloc.dart';
import '../../../../posts/presentation/bloc/profile_posts/event.dart';
import '../../../../posts/presentation/bloc/profile_posts/state.dart';
import '../../../../posts/presentation/utils/post_error_mapper.dart';
import '../../../../posts/presentation/widgets/post_card.dart';

/// The Posts tab content on a profile: a two-column grid of [PostCard]s backed by
/// [ProfilePostsBloc]. Tapping a card opens the full post.
class PostsSection extends StatelessWidget {
  final bool isOwner;

  const PostsSection({super.key, required this.isOwner});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: BlocBuilder<ProfilePostsBloc, ProfilePostsState>(
        builder: (context, state) {
          return switch (state) {
            ProfilePostsLoading() => const _PostsLoadingView(),
            ProfilePostsError(:final code) => _PostsErrorView(
                message: postErrorMessage(AppLocalizations.of(context)!, code),
              ),
            ProfilePostsLoaded(:final posts) => posts.isEmpty
                ? _PostsEmptyView(isOwner: isOwner)
                : _PostsGrid(state: state),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }
}

class _PostsGrid extends StatelessWidget {
  final ProfilePostsLoaded state;

  const _PostsGrid({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: state.posts.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 4 / 5,
          ),
          itemBuilder: (context, index) {
            final post = state.posts[index];
            return PostCard(
              post: post,
              onTap: () async {
                // The detail screen pops `true` when the post was edited or
                // deleted; refresh the grid so it reflects the change.
                final bloc = context.read<ProfilePostsBloc>();
                final changed = await context.push<bool>('/posts/${post.id}');
                if (changed == true) bloc.add(const ReloadPosts());
              },
            );
          },
        ),
        if (state.hasMore) ...[
          const SizedBox(height: 16),
          _LoadMoreButton(
            isLoading: state.isLoadingMore,
            onTap: () =>
                context.read<ProfilePostsBloc>().add(const LoadMorePosts()),
            label: l10n.postsLoadMore,
          ),
        ],
      ],
    );
  }
}

class _LoadMoreButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;
  final String label;

  const _LoadMoreButton({
    required this.isLoading,
    required this.onTap,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.line),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.mute,
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(
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

class _PostsEmptyView extends StatelessWidget {
  final bool isOwner;

  const _PostsEmptyView({required this.isOwner});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          const Icon(Icons.grid_on_outlined, size: 36, color: AppColors.mute),
          const SizedBox(height: 10),
          Text(
            isOwner ? l10n.postsEmptyOwner : l10n.postsEmptyVisitor,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.mute,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (isOwner) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => context.push('/posts/create'),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l10n.postsCreateFirst,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
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

class _PostsLoadingView extends StatelessWidget {
  const _PostsLoadingView();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: 4,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 4 / 5,
      ),
      itemBuilder: (_, _) => Container(
        decoration: BoxDecoration(
          color: AppColors.line,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class _PostsErrorView extends StatelessWidget {
  final String message;

  const _PostsErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.mute,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
