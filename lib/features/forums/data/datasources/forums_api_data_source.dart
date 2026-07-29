import 'package:injectable/injectable.dart';

import '../../../../core/network/abstract_http.dart';
import '../../domain/entities/forum_filter.dart';
import '../../domain/entities/forum_reply.dart';
import '../../domain/entities/forum_thread.dart';
import '../models/forum_models.dart';

/// Talks to `/forums/*` under the shared API base (`$API_BASE_URL/api/v1`).
/// Cursors are opaque and must be echoed back with the same sort they were
/// issued for; like/unlike and deletes return 204.
@lazySingleton
class ForumsApiDataSource {
  final AbstractHTTP http;

  ForumsApiDataSource(this.http);

  /// Flat list, already ordered by `sort_order`.
  Future<List<ForumTopicModel>> getTopics() async {
    final data = await http.get('/forums/topics');
    return (data as List<dynamic>)
        .map((e) => ForumTopicModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Picks the list endpoint from the filter: model beats brand, a topic
  /// narrows either of them via `?topic=`, and no car at all is the global
  /// feed. A topic on its own has no endpoint — it always rides on a hub.
  Future<ForumThreadPageModel> getThreads({
    ForumFilter? filter,
    required ForumThreadSort sort,
    String? cursor,
    int? size,
  }) async {
    final query = <String, dynamic>{
      'sort': sort.apiValue,
      'cursor': ?cursor,
      'size': ?size,
    };

    final String path;
    if (filter == null || filter.isEmpty) {
      path = '/forums/feed';
    } else {
      path = filter.model != null
          ? '/forums/models/${filter.model!.id}/threads'
          : '/forums/brands/${filter.brand!.id}/threads';
      if (filter.topic != null) query['topic'] = filter.topic!.id;
    }

    final data = await http.get(path, queryParameters: query);
    return ForumThreadPageModel.fromJson(data as Map<String, dynamic>);
  }

  Future<ForumThreadDetailModel> getThread(String threadId) async {
    final data = await http.get('/forums/threads/$threadId');
    return ForumThreadDetailModel.fromJson(data as Map<String, dynamic>);
  }

  Future<ForumReplyPageModel> getThreadReplies(
    String threadId, {
    ForumReplySort sort = ForumReplySort.oldest,
    String? cursor,
    int? size,
  }) async {
    final data = await http.get(
      '/forums/threads/$threadId/replies',
      queryParameters: {
        'sort': sort.apiValue,
        'cursor': ?cursor,
        'size': ?size,
      },
    );
    return ForumReplyPageModel.fromJson(data as Map<String, dynamic>);
  }

  Future<ForumReplyPageModel> getReplyChildren(
    String postId, {
    ForumReplySort sort = ForumReplySort.oldest,
    String? cursor,
    int? size,
  }) async {
    final data = await http.get(
      '/forums/replies/$postId/replies',
      queryParameters: {
        'sort': sort.apiValue,
        'cursor': ?cursor,
        'size': ?size,
      },
    );
    return ForumReplyPageModel.fromJson(data as Map<String, dynamic>);
  }

  Future<ForumThreadDetailModel> createThread({
    required String title,
    required String content,
    required String brandId,
    String? modelId,
    List<String> topicIds = const [],
    List<String> taggedPeople = const [],
    List<String> taggedCars = const [],
  }) async {
    final data = await http.post(
      '/forums/threads',
      body: {
        'title': title,
        'content': content,
        'brand_id': brandId,
        'model_id': ?modelId,
        if (topicIds.isNotEmpty) 'topic_ids': topicIds,
        if (taggedPeople.isNotEmpty) 'tagged_people': taggedPeople,
        if (taggedCars.isNotEmpty) 'tagged_cars': taggedCars,
      },
    );
    return ForumThreadDetailModel.fromJson(data as Map<String, dynamic>);
  }

  /// PATCH semantics for the tag lists: a null list is omitted (unchanged),
  /// a non-null one replaces the whole set (empty clears it).
  Future<ForumThreadDetailModel> editThread(
    String threadId, {
    required String content,
    List<String>? taggedPeople,
    List<String>? taggedCars,
  }) async {
    final data = await http.patch(
      '/forums/threads/$threadId',
      body: {
        'content': content,
        'tagged_people': ?taggedPeople,
        'tagged_cars': ?taggedCars,
      },
    );
    return ForumThreadDetailModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteThread(String threadId) =>
      http.delete('/forums/threads/$threadId');

  Future<ForumReplyModel> createReply(
    String threadId, {
    required String content,
    String? parentPostId,
    List<String> taggedPeople = const [],
    List<String> taggedCars = const [],
  }) async {
    final data = await http.post(
      '/forums/threads/$threadId/replies',
      body: {
        'content': content,
        'parent_post_id': ?parentPostId,
        if (taggedPeople.isNotEmpty) 'tagged_people': taggedPeople,
        if (taggedCars.isNotEmpty) 'tagged_cars': taggedCars,
      },
    );
    return ForumReplyModel.fromJson(data as Map<String, dynamic>);
  }

  /// Same PATCH semantics as [editThread]; [content] must be non-blank.
  Future<ForumReplyModel> editReply(
    String postId, {
    required String content,
    List<String>? taggedPeople,
    List<String>? taggedCars,
  }) async {
    final data = await http.patch(
      '/forums/replies/$postId',
      body: {
        'content': content,
        'tagged_people': ?taggedPeople,
        'tagged_cars': ?taggedCars,
      },
    );
    return ForumReplyModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteReply(String postId) =>
      http.delete('/forums/replies/$postId');

  Future<void> likeThread(String threadId) =>
      http.post('/forums/threads/$threadId/like');

  Future<void> unlikeThread(String threadId) =>
      http.delete('/forums/threads/$threadId/like');

  Future<void> likeReply(String postId) =>
      http.post('/forums/replies/$postId/like');

  Future<void> unlikeReply(String postId) =>
      http.delete('/forums/replies/$postId/like');

  Future<List<ForumShortcutModel>> getShortcuts() async {
    final data = await http.get('/forums/shortcuts');
    return (data as List<dynamic>)
        .map((e) => ForumShortcutModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ForumShortcutModel> createShortcut({
    required String name,
    String? brandId,
    String? modelId,
    String? topicId,
    bool notify = false,
  }) async {
    final data = await http.post(
      '/forums/shortcuts',
      body: {
        'name': name,
        'brand_id': ?brandId,
        'model_id': ?modelId,
        'topic_id': ?topicId,
        'notify': notify,
      },
    );
    return ForumShortcutModel.fromJson(data as Map<String, dynamic>);
  }

  /// Partial update — only the provided fields go on the wire.
  Future<ForumShortcutModel> updateShortcut(
    String shortcutId, {
    String? name,
    bool? notify,
  }) async {
    final data = await http.patch(
      '/forums/shortcuts/$shortcutId',
      body: {'name': ?name, 'notify': ?notify},
    );
    return ForumShortcutModel.fromJson(data as Map<String, dynamic>);
  }

  Future<List<ForumShortcutModel>> reorderShortcuts(
    List<String> orderedIds,
  ) async {
    final data = await http.patch(
      '/forums/shortcuts/reorder',
      body: {'ordered_ids': orderedIds},
    );
    return (data as List<dynamic>)
        .map((e) => ForumShortcutModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteShortcut(String shortcutId) =>
      http.delete('/forums/shortcuts/$shortcutId');

  // ── Saved threads (bookmarks) ────────────────────────────────────────────────

  /// Idempotent save/unsave; both return 204.
  Future<void> saveThread(String threadId) =>
      http.post('/forums/threads/$threadId/save');

  Future<void> unsaveThread(String threadId) =>
      http.delete('/forums/threads/$threadId/save');

  /// The viewer's saved threads, newest-save-first.
  Future<ForumThreadPageModel> getSavedThreads({
    String? cursor,
    int? size,
  }) async {
    final data = await http.get(
      '/forums/threads/saved',
      queryParameters: {'cursor': ?cursor, 'size': ?size},
    );
    return ForumThreadPageModel.fromJson(data as Map<String, dynamic>);
  }

  // ── Popular-hub suggestions ──────────────────────────────────────────────────

  Future<List<ForumSuggestionModel>> getSuggestions({int? limit}) async {
    final data = await http.get(
      '/forums/suggestions',
      queryParameters: {'limit': ?limit},
    );
    return (data as List<dynamic>)
        .map((e) => ForumSuggestionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
