import 'package:injectable/injectable.dart';

import '../../../../core/network/abstract_http.dart';
import '../models/post_comment_models.dart';
import '../models/post_models.dart';

/// Talks to the posts module under the shared API base (`$API_BASE_URL/api/v1`).
/// Image upload URLs are handled separately by [PostsStorageApiDataSource].
@lazySingleton
class PostsApiDataSource {
  final AbstractHTTP http;

  PostsApiDataSource(this.http);

  Future<PostModel> createPost(Map<String, dynamic> body) async {
    final data = await http.post('/posts', body: body);
    return PostModel.fromJson(data as Map<String, dynamic>);
  }

  Future<PostModel> saveImageKeys(String postId, List<String> keys) async {
    final data = await http.patch(
      '/posts/$postId/images',
      body: {'keys': keys},
    );
    return PostModel.fromJson(data as Map<String, dynamic>);
  }

  Future<PostModel> getPost(String postId) async {
    final data = await http.get('/posts/$postId');
    return PostModel.fromJson(data as Map<String, dynamic>);
  }

  Future<PostPageModel> getMyPosts({String? cursor, int size = 20}) async {
    final data = await http.get(
      '/posts/me',
      queryParameters: {
        'cursor': ?cursor,
        'size': size,
      },
    );
    return PostPageModel.fromJson(data as Map<String, dynamic>);
  }

  Future<PostPageModel> getPostsByUsername(
    String username, {
    String? cursor,
    int size = 20,
  }) async {
    final data = await http.get(
      '/posts/by-username/$username',
      queryParameters: {
        'cursor': ?cursor,
        'size': size,
      },
    );
    return PostPageModel.fromJson(data as Map<String, dynamic>);
  }

  Future<PostPageModel> getSavedPosts({String? cursor, int size = 20}) async {
    final data = await http.get(
      '/posts/saved',
      queryParameters: {
        'cursor': ?cursor,
        'size': size,
      },
    );
    return PostPageModel.fromJson(data as Map<String, dynamic>);
  }

  Future<PostModel> updatePost(
    String postId,
    Map<String, dynamic> body,
  ) async {
    final data = await http.patch('/posts/$postId', body: body);
    return PostModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deletePost(String postId) async {
    await http.delete('/posts/$postId');
  }

  Future<CommentPageModel> getComments(
    String postId, {
    String? cursor,
    int size = 20,
  }) async {
    final data = await http.get(
      '/posts/$postId/comments',
      queryParameters: {
        'cursor': ?cursor,
        'size': size,
      },
    );
    return CommentPageModel.fromJson(data as Map<String, dynamic>);
  }

  Future<LikerPageModel> getLikers(
    String postId, {
    String? cursor,
    int size = 20,
  }) async {
    final data = await http.get(
      '/posts/$postId/likes',
      queryParameters: {
        'cursor': ?cursor,
        'size': size,
      },
    );
    return LikerPageModel.fromJson(data as Map<String, dynamic>);
  }

  // ── Engagement — likes / saves / shares (idempotent, no body) ────────────────

  Future<void> likePost(String postId) async {
    await http.post('/posts/$postId/likes');
  }

  Future<void> unlikePost(String postId) async {
    await http.delete('/posts/$postId/likes');
  }

  Future<void> savePost(String postId) async {
    await http.post('/posts/$postId/saves');
  }

  Future<void> unsavePost(String postId) async {
    await http.delete('/posts/$postId/saves');
  }

  /// Plain share when [content] is null; a non-null [content] quote-shares.
  /// Callers pass null for a plain share, so the body is empty in that case.
  Future<void> sharePost(String postId, {String? content}) async {
    await http.post('/posts/$postId/shares', body: {'content': ?content});
  }

  Future<void> unsharePost(String postId) async {
    await http.delete('/posts/$postId/shares');
  }

  // ── Comments ─────────────────────────────────────────────────────────────────

  /// Tag ids are only sent when non-empty, so an untagged comment keeps the
  /// exact body shape the backend has always received.
  Future<PostCommentModel> addComment(
    String postId, {
    required String content,
    String? parentCommentId,
    List<String> taggedPeople = const [],
    List<String> taggedCars = const [],
  }) async {
    final data = await http.post(
      '/posts/$postId/comments',
      body: {
        'content': content,
        'parent_comment_id': ?parentCommentId,
        if (taggedPeople.isNotEmpty) 'tagged_people': taggedPeople,
        if (taggedCars.isNotEmpty) 'tagged_cars': taggedCars,
      },
    );
    return PostCommentModel.fromJson(data as Map<String, dynamic>);
  }

  Future<CommentPageModel> getReplies(
    String postId,
    String commentId, {
    String? cursor,
    int size = 20,
  }) async {
    final data = await http.get(
      '/posts/$postId/comments/$commentId/replies',
      queryParameters: {
        'cursor': ?cursor,
        'size': size,
      },
    );
    return CommentPageModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteComment(String postId, String commentId) async {
    await http.delete('/posts/$postId/comments/$commentId');
  }

  Future<void> likeComment(String postId, String commentId) async {
    await http.post('/posts/$postId/comments/$commentId/likes');
  }

  Future<void> unlikeComment(String postId, String commentId) async {
    await http.delete('/posts/$postId/comments/$commentId/likes');
  }
}
