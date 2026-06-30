import 'package:dartz/dartz.dart';

import '../../../../core/error/base_failures.dart';
import '../../../posts/domain/entities/post_pages.dart';

/// The global, virality-ranked feed. Returns the shared [PostPageEntity] from
/// the posts feature — a feed item *is* a post, so it reuses the same entity.
abstract class FeedRepository {
  /// Fetches one page of the global feed. [cursor] is the opaque `nextCursor`
  /// from the previous page (null for the first page); a null `nextCursor` in
  /// the result means the last page has been reached.
  Future<Either<Failure, PostPageEntity>> getGlobalFeed({
    String? cursor,
    int size = 20,
  });
}
