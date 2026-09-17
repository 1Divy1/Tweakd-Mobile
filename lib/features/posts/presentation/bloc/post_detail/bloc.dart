import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/usecases/delete_post.dart';
import '../../../domain/usecases/get_post.dart';
import '../../../domain/usecases/post_like.dart';
import '../../../domain/usecases/post_repost.dart';
import '../../../domain/usecases/post_save.dart';
import '../../utils/post_error_mapper.dart';
import 'event.dart';
import 'state.dart';

/// Drives a single post's detail view: load, like/save/repost toggles
/// (optimistic), and delete. Edits arrive via [PostUpdated] from the edit screen.
@injectable
class PostDetailBloc extends Bloc<PostDetailEvent, PostDetailState> {
  final GetPostUseCase getPost;
  final LikePostUseCase likePost;
  final UnlikePostUseCase unlikePost;
  final SavePostUseCase savePost;
  final UnsavePostUseCase unsavePost;
  final RepostPostUseCase repostPost;
  final UnrepostPostUseCase unrepostPost;
  final DeletePostUseCase deletePost;

  PostDetailBloc({
    required this.getPost,
    required this.likePost,
    required this.unlikePost,
    required this.savePost,
    required this.unsavePost,
    required this.repostPost,
    required this.unrepostPost,
    required this.deletePost,
  }) : super(const PostDetailLoading()) {
    on<LoadPost>(_onLoad);
    on<ToggleLikePost>(_onToggleLike);
    on<ToggleSavePost>(_onToggleSave);
    on<ToggleRepostPost>(_onToggleRepost);
    on<DeletePostPressed>(_onDelete);
    on<PostUpdated>(_onUpdated);
    on<CommentCountChanged>(_onCommentCountChanged);
  }

  void _onCommentCountChanged(
    CommentCountChanged event,
    Emitter<PostDetailState> emit,
  ) {
    final current = state;
    if (current is! PostDetailLoaded) return;
    emit(current.copyWith(
      post: current.post.copyWith(commentsCount: event.count),
    ));
  }

  Future<void> _onLoad(LoadPost event, Emitter<PostDetailState> emit) async {
    emit(const PostDetailLoading());
    final result = await getPost(GetPostParams(postId: event.postId));
    result.fold(
      (failure) => emit(PostDetailError(PostErrorMapper.getCode(failure))),
      (post) => emit(PostDetailLoaded(post: post)),
    );
  }

  Future<void> _onToggleLike(
    ToggleLikePost event,
    Emitter<PostDetailState> emit,
  ) async {
    final current = state;
    if (current is! PostDetailLoaded) return;
    final post = current.post;
    final liked = post.viewerHasLiked;

    // Optimistic flip; revert on failure.
    emit(current.copyWith(
      post: post.copyWith(
        viewerHasLiked: !liked,
        likesCount: (post.likesCount + (liked ? -1 : 1)).clamp(0, 1 << 31),
      ),
    ));

    final params = PostIdParams(postId: post.id);
    final result = liked ? await unlikePost(params) : await likePost(params);
    result.fold((_) => emit(current), (_) {});
  }

  Future<void> _onToggleSave(
    ToggleSavePost event,
    Emitter<PostDetailState> emit,
  ) async {
    final current = state;
    if (current is! PostDetailLoaded) return;
    final post = current.post;
    final saved = post.viewerHasSaved;

    emit(current.copyWith(
      post: post.copyWith(
        viewerHasSaved: !saved,
        savedCount: (post.savedCount + (saved ? -1 : 1)).clamp(0, 1 << 31),
      ),
    ));

    final params = PostIdParams(postId: post.id);
    final result = saved ? await unsavePost(params) : await savePost(params);
    result.fold((_) => emit(current), (_) {});
  }

  Future<void> _onToggleRepost(
    ToggleRepostPost event,
    Emitter<PostDetailState> emit,
  ) async {
    final current = state;
    if (current is! PostDetailLoaded) return;
    final post = current.post;
    final reposted = post.viewerHasReposted;

    emit(current.copyWith(
      post: post.copyWith(
        viewerHasReposted: !reposted,
        sharesCount: (post.sharesCount + (reposted ? -1 : 1)).clamp(0, 1 << 31),
      ),
    ));

    final params = PostIdParams(postId: post.id);
    final result =
        reposted ? await unrepostPost(params) : await repostPost(params);
    result.fold((_) => emit(current), (_) {});
  }

  Future<void> _onDelete(
    DeletePostPressed event,
    Emitter<PostDetailState> emit,
  ) async {
    final current = state;
    if (current is! PostDetailLoaded || current.isDeleting) return;

    emit(current.copyWith(isDeleting: true));
    final result = await deletePost(DeletePostParams(postId: current.post.id));
    result.fold(
      (failure) {
        emit(PostDetailError(PostErrorMapper.getCode(failure)));
        emit(current.copyWith(isDeleting: false));
      },
      (_) => emit(const PostDetailDeleted()),
    );
  }

  void _onUpdated(PostUpdated event, Emitter<PostDetailState> emit) {
    // The edit endpoint returns the full, re-assembled post (PostDto), so the
    // updated entity can replace the held one wholesale.
    emit(PostDetailLoaded(post: event.post));
  }
}
