import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/widgets/app_bottom_nav.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../posts/domain/entities/post.dart';
import '../../../posts/presentation/widgets/post_detail/comments_sheet.dart';
import '../../../posts/presentation/widgets/post_detail/likers_sheet.dart';
import '../bloc/feed/bloc.dart';
import '../bloc/feed/event.dart';
import '../bloc/feed/state.dart';
import '../utils/feed_error_mapper.dart';
import '../widgets/feed_empty_view.dart';
import '../widgets/feed_error_view.dart';
import '../widgets/feed_loading_view.dart';
import '../widgets/feed_post_card.dart';
import '../widgets/feed_top_bar.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const FeedTopBar(),
            Expanded(
              child: BlocBuilder<FeedBloc, FeedState>(
                builder: (context, state) {
                  return switch (state) {
                    FeedInitial() || FeedLoading() => const FeedLoadingView(),
                    FeedError(:final code) => FeedErrorView(
                        message: feedErrorMessage(
                          AppLocalizations.of(context)!,
                          code,
                        ),
                        onRetry: () =>
                            context.read<FeedBloc>().add(const LoadFeed()),
                      ),
                    FeedLoaded() => _FeedList(state: state),
                  };
                },
              ),
            ),
            const AppBottomNav(activeTab: AppBottomNavTab.feed),
          ],
        ),
      ),
    );
  }
}

/// The loaded feed list: pull-to-refresh, cursor paging on scroll, and a
/// trailing loader / empty state.
class _FeedList extends StatefulWidget {
  final FeedLoaded state;
  const _FeedList({required this.state});

  @override
  State<_FeedList> createState() => _FeedListState();
}

class _FeedListState extends State<_FeedList> {
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
      context.read<FeedBloc>().add(const LoadMoreFeed());
    }
  }

  Future<void> _refresh() async {
    // A Completer (not a state-change listener) drives the indicator: a refresh
    // that returns identical data emits no new state, so waiting on the stream
    // would hang the spinner forever.
    final completer = Completer<void>();
    context.read<FeedBloc>().add(RefreshFeed(completer));
    await completer.future;
  }

  void _openPost(PostEntity post) {
    context.push('/posts/${post.id}');
  }

  void _openComments(PostEntity post) {
    final bloc = context.read<FeedBloc>();
    showCommentsSheet(
      context,
      postId: post.id,
      initialCount: post.commentsCount,
      postOwnerId: post.author.id,
      onCountChanged: (count) =>
          bloc.add(UpdateFeedPostCommentCount(post.id, count)),
    );
  }

  Future<void> _share(PostEntity post) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final shared = await context.push<bool>(
      '/posts/${post.id}/share',
      extra: post,
    );
    if (shared == true) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.postShareSuccess)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final posts = widget.state.posts;

    if (posts.isEmpty) {
      return RefreshIndicator(
        color: AppColors.accent,
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 120),
            FeedEmptyView(),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.accent,
      onRefresh: _refresh,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        itemCount: posts.length + 1,
        itemBuilder: (context, index) {
          if (index == posts.length) {
            return _Footer(isLoadingMore: widget.state.isLoadingMore);
          }
          final post = posts[index];
          return FeedPostCard(
            post: post,
            onToggleLike: () =>
                context.read<FeedBloc>().add(ToggleLikeFeedPost(post.id)),
            onToggleSave: () =>
                context.read<FeedBloc>().add(ToggleSaveFeedPost(post.id)),
            onShare: () => _share(post),
            onOpenComments: () => _openComments(post),
            onOpenLikers: () => showLikersSheet(context, postId: post.id),
            onSubmitComment: (text) =>
                context.read<FeedBloc>().add(SubmitFeedComment(post.id, text)),
            onMenu: () => _openPost(post),
          );
        },
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final bool isLoadingMore;
  const _Footer({required this.isLoadingMore});

  @override
  Widget build(BuildContext context) {
    if (!isLoadingMore) return const SizedBox(height: 8);
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent),
        ),
      ),
    );
  }
}
