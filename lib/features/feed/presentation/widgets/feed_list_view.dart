import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/shared/utils/scroll_to_top.dart';
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
import 'feed_new_posts_pill.dart';
import 'feed_post_card.dart';
import '../../../../core/shared/layout/app_layout.dart';

/// The loaded feed list: pull-to-refresh, cursor paging on scroll, and a
/// trailing loader / empty state.
///
/// On a launch that opened on the cached page it also shows the refresh in
/// progress (a thin line along the top), reports the user's first scroll so
/// the fresh page knows not to swap in under them, and floats the "New posts"
/// pill when that page is waiting.
class FeedListView extends StatefulWidget {
  final FeedLoaded state;

  /// Opens the post composer from the empty state.
  final VoidCallback onCreatePost;

  /// Fires when the home tab is tapped while already on it: scroll back to
  /// the top and refresh.
  final Listenable? reselected;

  const FeedListView({
    super.key,
    required this.state,
    required this.onCreatePost,
    this.reselected,
  });

  @override
  State<FeedListView> createState() => _FeedListViewState();
}

class _FeedListViewState extends State<FeedListView> {
  final _scrollController = ScrollController();
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  /// Set once the cached-page scroll has been reported; it only matters once.
  bool _reportedCacheScroll = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    widget.reselected?.addListener(_scrollToTopAndRefresh);
  }

  @override
  void didUpdateWidget(FeedListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reselected != widget.reselected) {
      oldWidget.reselected?.removeListener(_scrollToTopAndRefresh);
      widget.reselected?.addListener(_scrollToTopAndRefresh);
    }
  }

  @override
  void dispose() {
    widget.reselected?.removeListener(_scrollToTopAndRefresh);
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

  /// Only a drag counts: the list settling or a programmatic jump isn't the
  /// user reading.
  bool _onScrollStart(ScrollStartNotification notification) {
    if (widget.state.isCached &&
        !_reportedCacheScroll &&
        notification.dragDetails != null) {
      _reportedCacheScroll = true;
      context.read<FeedBloc>().add(const FeedCacheScrolled());
    }
    return false;
  }

  void _showNewPosts() {
    context.read<FeedBloc>().add(const ShowNewFeedPosts());
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
  }

  /// Shows the pull-to-refresh spinner rather than refreshing silently, so the
  /// tap visibly did something.
  Future<void> _scrollToTopAndRefresh() async {
    await scrollToTop(_scrollController);
    if (mounted) _refreshKey.currentState?.show();
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

  @override
  Widget build(BuildContext context) {
    final posts = widget.state.posts;
    final currentUserId = getIt<SupabaseClient>().auth.currentUser?.id;

    if (posts.isEmpty) {
      return RefreshIndicator(
        key: _refreshKey,
        color: AppColors.accent,
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppLayout.inset(context),
          children: [
            const SizedBox(height: 96),
            FeedEmptyView(onCreatePost: widget.onCreatePost),
          ],
        ),
      );
    }

    final state = widget.state;
    return Stack(
      children: [
        NotificationListener<ScrollStartNotification>(
          onNotification: _onScrollStart,
          child: RefreshIndicator(
            key: _refreshKey,
            color: AppColors.accent,
            onRefresh: _refresh,
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding:
                  const EdgeInsets.only(top: 8, bottom: 16) +
                  AppLayout.inset(context),
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
                  // Your own post can't be reposted; its count still shows.
                  onToggleRepost: post.author.id == currentUserId
                      ? null
                      : () => context.read<FeedBloc>().add(
                          ToggleRepostFeedPost(post.id),
                        ),
                  onOpenComments: () => _openComments(post),
                  onOpenLikers: () => showLikersSheet(context, postId: post.id),
                  onSubmitComment: (text) => context.read<FeedBloc>().add(
                    SubmitFeedComment(post.id, text),
                  ),
                  onMenu: () => _openPostMenu(post),
                );
              },
            ),
          ),
        ),
        if (state.isRefreshing)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              minHeight: 2,
              color: AppColors.accent,
              backgroundColor: Colors.transparent,
            ),
          ),
        if (state.newPage != null)
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Center(child: FeedNewPostsPill(onTap: _showNewPosts)),
          ),
      ],
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
