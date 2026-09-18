import 'package:injectable/injectable.dart';

import '../../../../core/network/abstract_http.dart';
import '../models/feed_page_model.dart';

/// Talks to the feed module under the shared API base (`$API_BASE_URL/api/v1`).
/// A feed item is the same `PostDto` the posts endpoints return; the first page
/// additionally carries `pending_badge_celebrations`, so the response is parsed
/// with [FeedPageModel] (snake_case).
@lazySingleton
class FeedApiDataSource {
  final AbstractHTTP http;

  FeedApiDataSource(this.http);

  /// GET /feed/global — virality-ranked global feed, cursor-paginated. With no
  /// `cursor` the response embeds any pending badge celebrations; paged
  /// requests carry an empty list.
  Future<FeedPageModel> getGlobalFeed({String? cursor, int size = 20}) async {
    return FeedPageModel.fromJson(
      await getGlobalFeedJson(cursor: cursor, size: size),
    );
  }

  /// The same request as [getGlobalFeed], returning the body unparsed — for the
  /// first page, which is also saved to disk as-is.
  Future<Map<String, dynamic>> getGlobalFeedJson({
    String? cursor,
    int size = 20,
  }) async {
    final data = await http.get(
      '/feed/global',
      queryParameters: {'cursor': ?cursor, 'size': size},
    );
    return data as Map<String, dynamic>;
  }
}
