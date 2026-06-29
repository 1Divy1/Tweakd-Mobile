import 'dart:typed_data';

import 'package:dartz/dartz.dart';

import '../../../../core/error/base_failures.dart';
import '../entities/post.dart';
import '../entities/post_comment.dart';
import '../entities/post_params.dart';
import '../entities/post_pages.dart';
import '../entities/post_upload.dart';

abstract class PostsRepository {
  // ── Create + images ────────────────────────────────────────────────────────

  /// Creates a post from text data only. The returned post has no images yet.
  Future<Either<Failure, PostEntity>> createPost(CreatePostParams params);

  /// Requests [count] presigned R2 upload slots for a post's images.
  Future<Either<Failure, PostUploadUrlsResult>> getImageUploadUrls(
    String postId,
    int count,
  );

  /// PUTs WebP [bytes] directly to a presigned R2 [uploadUrl].
  Future<Either<Failure, void>> uploadImageToR2(
    String uploadUrl,
    Uint8List bytes,
  );

  /// Commits the final ordered list of R2 [keys] to the post (display order).
  /// Fully replaces any existing images; an empty list clears them.
  Future<Either<Failure, PostEntity>> saveImageKeys(
    String postId,
    List<String> keys,
  );

  // ── Read ───────────────────────────────────────────────────────────────────

  Future<Either<Failure, PostEntity>> getPost(String postId);

  Future<Either<Failure, PostPageEntity>> getMyPosts({
    String? cursor,
    int size,
  });

  Future<Either<Failure, PostPageEntity>> getPostsByUsername(
    String username, {
    String? cursor,
    int size,
  });

  Future<Either<Failure, CommentPageEntity>> getComments(
    String postId, {
    String? cursor,
    int size,
  });

  Future<Either<Failure, LikerPageEntity>> getLikers(
    String postId, {
    String? cursor,
    int size,
  });

  // ── Mutate ─────────────────────────────────────────────────────────────────

  Future<Either<Failure, PostEntity>> updatePost(
    String postId,
    UpdatePostParams params,
  );

  Future<Either<Failure, void>> deletePost(String postId);

  // ── Engagement ───────────────────────────────────────────────────────────────

  Future<Either<Failure, void>> likePost(String postId);

  Future<Either<Failure, void>> unlikePost(String postId);

  Future<Either<Failure, void>> savePost(String postId);

  Future<Either<Failure, void>> unsavePost(String postId);

  Future<Either<Failure, void>> sharePost(String postId, {String? content});

  Future<Either<Failure, void>> unsharePost(String postId);

  // ── Comments ─────────────────────────────────────────────────────────────────

  Future<Either<Failure, PostCommentEntity>> addComment(
    String postId, {
    required String content,
    String? parentCommentId,
  });

  /// Direct replies to [commentId] on [postId], newest first.
  Future<Either<Failure, CommentPageEntity>> getReplies(
    String postId,
    String commentId, {
    String? cursor,
    int size,
  });

  Future<Either<Failure, void>> deleteComment(String postId, String commentId);

  Future<Either<Failure, void>> likeComment(String postId, String commentId);

  Future<Either<Failure, void>> unlikeComment(String postId, String commentId);
}
