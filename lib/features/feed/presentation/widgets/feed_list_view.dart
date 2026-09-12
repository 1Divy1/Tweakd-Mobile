import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../posts/domain/entities/post.dart';
import '../../../posts/presentation/widgets/post_card/post_options_sheet.dart';
import '../../../posts/presentation/widgets/post_detail/comments_sheet.dart';
import '../../../posts/presentation/widgets/post_detail/likers_sheet.dart';
import '../../../report/domain/entities/report_target.dart';
import '../../../report/presentation/widgets/report_reason_sheet.dart';
import '../bloc/feed/bloc.dart';
import '../bloc/feed/event.dart';
import '../bloc/feed/state.dart';
import 'feed_empty_view.dart';
import 'feed_post_card.dart';

/// The loaded feed list: pull-to-refresh, cursor paging on scroll, and a
/// trailing loader / empty state.
class FeedListView extends StatefulWidget {
  final FeedLoaded state;

  /// Opens the post composer from the empty state.
  final VoidCallback onCreatePost;

  const FeedListView({
    super.key,
    required this.state,
    required this.onCreatePost,
  });

  @override
  State<FeedListView> createState() => _FeedListViewState();
}

class _FeedListViewState extends State<FeedListView> {
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

  /// Opens the post "⋯" menu; if the viewer reports the post, hide it so the
  /// next post takes its place.
  Future<void> _openPostMenu(PostEntity post) async {
    final l10n = AppLocalizations.of(context)!;
    final feedBloc = context.read<FeedBloc>();

    final action = await showPostOptionsSheet(context);
    if (action != PostMenuAction.report || !mounted) return;

    final reported = await showReportSheet(
      context,
      target: PostReportTarget(post.id),
      title: l10n.postReport,
    );
    if (reported) feedBloc.add(HideFeedPost(post.id));
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
          children: [
            const SizedBox(height: 96),
            FeedEmptyView(onCreatePost: widget.onCreatePost),
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
            key: ValueKey(post.id),
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
            onMenu: () => _openPostMenu(post),
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
    return Padding(
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
    );
  }
}
