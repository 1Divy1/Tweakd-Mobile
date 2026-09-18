import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_icons.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../posts/presentation/bloc/profile_posts/event.dart';
import '../../../../posts/presentation/bloc/profile_posts/state.dart';
import '../../../../posts/presentation/utils/post_error_mapper.dart';
import '../../../../posts/presentation/widgets/post_card.dart';

/// Which grid a [PostsSection] is: the user's own posts, or the posts they
/// reposted. Only the empty state differs.
enum PostsSectionKind { posts, reposts }

/// The Posts or Reposts tab content on a profile: an edge-to-edge three-column
/// grid of [PostCard]s backed by [B] — `ProfilePostsBloc` or
/// `ProfileRepostsBloc`, which speak the same events and states. Tapping a card
/// opens the full post.
///
/// The grid itself is full-bleed (no side padding, hairline gaps); the empty,
/// error and load-more states keep the page's 20px horizontal margin so they
/// read as centred cards rather than stretched banners.
class PostsSection<B extends Bloc<ProfilePostsEvent, ProfilePostsState>>
    extends StatelessWidget {
  final bool isOwner;
  final PostsSectionKind kind;

  const PostsSection({
    super.key,
    required this.isOwner,
    this.kind = PostsSectionKind.posts,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<B, ProfilePostsState>(
      builder: (context, state) {
        return switch (state) {
          // A lazily loaded tab is still Initial for the frame before its
          // first load lands.
          ProfilePostsInitial() ||
          ProfilePostsLoading() => const _PostsLoadingView(),
          ProfilePostsError(:final code) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _PostsErrorView(
              message: postErrorMessage(AppLocalizations.of(context)!, code),
            ),
          ),
          ProfilePostsLoaded(:final posts) =>
            posts.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _PostsEmptyView(isOwner: isOwner, kind: kind),
                  )
                : _PostsGrid<B>(state: state),
        };
      },
    );
  }
}

class _PostsGrid<B extends Bloc<ProfilePostsEvent, ProfilePostsState>>
    extends StatelessWidget {
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
            crossAxisCount: 3,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final post = state.posts[index];
            return PostCard(
              post: post,
              onTap: () async {
                // The detail screen pops `true` when the post was edited or
                // deleted; refresh the grid so it reflects the change.
                final bloc = context.read<B>();
                final changed = await context.push<bool>('/posts/${post.id}');
                if (changed == true) bloc.add(const ReloadPosts());
              },
            );
          },
        ),
        if (state.hasMore) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _LoadMoreButton(
              isLoading: state.isLoadingMore,
              onTap: () => context.read<B>().add(const LoadMorePosts()),
              label: l10n.postsLoadMore,
            ),
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

class _PostsEmptyView extends StatelessWidget {
  final bool isOwner;
  final PostsSectionKind kind;

  const _PostsEmptyView({required this.isOwner, required this.kind});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final reposts = kind == PostsSectionKind.reposts;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(
            reposts ? AppIcons.repost : Icons.grid_on_outlined,
            size: 36,
            color: AppColors.mute,
          ),
          const SizedBox(height: 10),
          Text(
            switch ((reposts, isOwner)) {
              (false, true) => l10n.postsEmptyOwner,
              (false, false) => l10n.postsEmptyVisitor,
              (true, true) => l10n.repostsEmptyOwner,
              (true, false) => l10n.repostsEmptyVisitor,
            },
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.mute,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          // Reposts are made from other people's posts, so there is nothing
          // to create from here.
          if (isOwner && !reposts) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => context.push('/posts/create'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  l10n.postsCreateFirst,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
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
      itemCount: 9,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        childAspectRatio: 1,
      ),
      itemBuilder: (_, _) => ColoredBox(color: AppColors.line),
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
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.mute,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
