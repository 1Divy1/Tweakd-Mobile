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
}
