import 'package:dartz/dartz.dart';

import 'package:car_social_media_app/core/error/base_failures.dart';

import '../entities/forum_filter.dart';
import '../entities/forum_pages.dart';
import '../entities/forum_reply.dart';
import '../entities/forum_shortcut.dart';
import '../entities/forum_suggestion.dart';
import '../entities/forum_thread.dart';
import '../entities/forum_topic.dart';

abstract class ForumsRepository {
  Future<Either<Failure, List<ForumTopicEntity>>> getTopics();

  /// Thread lists. An empty/null [filter] hits the global forums feed;
  /// otherwise the brand / model / topic endpoint matching the filter.
  Future<Either<Failure, ForumThreadPageEntity>> getThreads({
    ForumFilter? filter,
    required ForumThreadSort sort,
    String? cursor,
    int? size,
  });

  Future<Either<Failure, ForumThreadDetailEntity>> getThread(String threadId);

  /// Top-level replies of a thread. [sort] picks oldest- or newest-first.
  Future<Either<Failure, ForumReplyPageEntity>> getThreadReplies(
    String threadId, {
    ForumReplySort sort,
    String? cursor,
    int? size,
  });

  /// One page of a reply's direct children, in the given [sort].
  Future<Either<Failure, ForumReplyPageEntity>> getReplyChildren(
    String postId, {
    ForumReplySort sort,
    String? cursor,
    int? size,
  });

  Future<Either<Failure, ForumThreadDetailEntity>> createThread({
    required String title,
    String? content,
    String? modelId,
    String? brandId,
    List<String> topicIds,
  });

  /// Author-only edit of the OP body (title/topics/car are immutable).
  Future<Either<Failure, ForumThreadDetailEntity>> editThread(
    String threadId, {
    required String content,
  });

  Future<Either<Failure, void>> deleteThread(String threadId);

  Future<Either<Failure, ForumReplyEntity>> createReply(
    String threadId, {
    required String content,
    String? parentPostId,
  });

  Future<Either<Failure, ForumReplyEntity>> editReply(
    String postId, {
    required String content,
  });

  Future<Either<Failure, void>> deleteReply(String postId);

  Future<Either<Failure, void>> likeThread(String threadId);
  Future<Either<Failure, void>> unlikeThread(String threadId);
  Future<Either<Failure, void>> likeReply(String postId);
  Future<Either<Failure, void>> unlikeReply(String postId);

  /// Shortcuts in pinned order.
  Future<Either<Failure, List<ForumShortcutEntity>>> getShortcuts();

  Future<Either<Failure, ForumShortcutEntity>> createShortcut({
    required String name,
    String? brandId,
    String? modelId,
    String? topicId,
    bool notify,
  });

  /// Partial update: only non-null fields are sent (the filter is immutable).
  Future<Either<Failure, ForumShortcutEntity>> updateShortcut(
    String shortcutId, {
    String? name,
    bool? notify,
  });

  /// [orderedIds] must contain every shortcut id exactly once.
  Future<Either<Failure, List<ForumShortcutEntity>>> reorderShortcuts(
    List<String> orderedIds,
  );

  Future<Either<Failure, void>> deleteShortcut(String shortcutId);

  /// Idempotent save/unsave (bookmark) of a thread.
  Future<Either<Failure, void>> saveThread(String threadId);
  Future<Either<Failure, void>> unsaveThread(String threadId);

  /// The viewer's saved threads, newest-save-first.
  Future<Either<Failure, ForumThreadPageEntity>> getSavedThreads({
    String? cursor,
    int? size,
  });

  /// The most active brands, models and topics, ranked by thread count.
  Future<Either<Failure, List<ForumSuggestionEntity>>> getSuggestions({
    int? limit,
  });
}
