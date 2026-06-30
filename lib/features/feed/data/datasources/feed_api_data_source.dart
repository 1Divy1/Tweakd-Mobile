import 'package:injectable/injectable.dart';

import '../../../../core/network/abstract_http.dart';
import '../../../posts/data/models/post_models.dart';

/// Talks to the feed module under the shared API base (`$API_BASE_URL/api/v1`).
/// A feed item is the same `PostDto` the posts endpoints return, so the
/// response is parsed with the posts feature's [PostPageModel] (snake_case).
@lazySingleton
class FeedApiDataSource {
  final AbstractHTTP http;

  FeedApiDataSource(this.http);

  /// GET /feed/global — virality-ranked global feed, cursor-paginated.
  Future<PostPageModel> getGlobalFeed({String? cursor, int size = 20}) async {
    final data = await http.get(
      '/feed/global',
      queryParameters: {
        'cursor': ?cursor,
        'size': size,
      },
    );
    return PostPageModel.fromJson(data as Map<String, dynamic>);
  }
}
