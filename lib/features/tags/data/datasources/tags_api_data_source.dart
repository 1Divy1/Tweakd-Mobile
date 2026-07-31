import 'package:injectable/injectable.dart';

import '../../../../core/network/abstract_http.dart';
import '../../domain/entities/tagged_item.dart';
import '../models/tagged_item_models.dart';

/// Talks to the tags module under the shared API base (`$API_BASE_URL/api/v1`).
/// It owns no data of its own — the two GETs are a merged read across posts,
/// comments, threads and replies, and the DELETE is the untag action.
@lazySingleton
class TagsApiDataSource {
  final AbstractHTTP http;

  TagsApiDataSource(this.http);

  Future<TaggedItemPageModel> getMyTags({String? cursor, int size = 20}) async {
    final data = await http.get(
      '/tags/me',
      queryParameters: {
        'cursor': ?cursor,
        'size': size,
      },
    );
    return TaggedItemPageModel.fromJson(data as Map<String, dynamic>);
  }

  Future<TaggedItemPageModel> getTagsByUsername(
    String username, {
    String? cursor,
    int size = 20,
  }) async {
    final data = await http.get(
      '/tags/by-username/$username',
      queryParameters: {
        'cursor': ?cursor,
        'size': size,
      },
    );
    return TaggedItemPageModel.fromJson(data as Map<String, dynamic>);
  }

  /// 204 No Content. Idempotent — untagging content you aren't tagged in
  /// succeeds silently.
  Future<void> removeTag(TaggedItemKind kind, String targetId) =>
      http.delete('/tags/${kind.apiValue}/$targetId');
}
