import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../bloc/saved_posts/bloc.dart';
import '../../bloc/saved_posts/event.dart';
import '../../bloc/saved_posts/state.dart';
import '../post_card.dart';

/// The loaded saved-posts grid: pull-to-refresh, cursor pagination near the
/// bottom, and the same edge-to-edge three-column [PostCard] look as the profile
/// Posts tab. Tapping a card pushes the post detail; on return the list is
/// unconditionally refreshed so an unsave (or any other change) made there is
/// reflected here.
class SavedPostsGridView extends StatelessWidget {
  final SavedPostsLoaded state;

  const SavedPostsGridView({super.key, required this.state});

  Future<void> _refresh(BuildContext context) async {
    final completer = Completer<void>();
    context.read<SavedPostsBloc>().add(RefreshSavedPosts(completer));
    await completer.future;
  }

  bool _onScroll(BuildContext context, ScrollNotification notification) {
    if (notification.metrics.extentAfter < 300) {
      context.read<SavedPostsBloc>().add(const LoadMoreSavedPosts());
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final posts = state.posts;
    final bloc = context.read<SavedPostsBloc>();

    return RefreshIndicator(
      color: AppColors.accent,
      onRefresh: () => _refresh(context),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) => _onScroll(context, notification),
        child: GridView.builder(
          padding: const EdgeInsets.only(top: 2, bottom: 24),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: posts.length + (state.isLoadingMore ? 1 : 0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            if (index >= posts.length) {
              return Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.accent,
                  ),
                ),
              );
            }
            final post = posts[index];
            return PostCard(
              post: post,
              onTap: () async {
                await context.push('/posts/${post.id}');
                bloc.add(const RefreshSavedPosts());
              },
            );
          },
        ),
      ),
    );
  }
}
