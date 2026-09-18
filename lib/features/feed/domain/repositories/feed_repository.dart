import 'package:dartz/dartz.dart';

import '../../../../core/error/base_failures.dart';
import '../entities/feed_page.dart';

/// The global, virality-ranked feed.
abstract class FeedRepository {
  /// Fetches one page of the global feed. [cursor] is the opaque `nextCursor`
  /// from the previous page (null for the first page); a null `nextCursor` in
  /// the result means the last page has been reached.
  ///
  /// The first page ([cursor] null) additionally carries
  /// [FeedPageEntity.pendingBadgeCelebrations]; paged results carry an empty
  /// list.
  Future<Either<Failure, FeedPageEntity>> getGlobalFeed({
    String? cursor,
    int size = 20,
  });

  /// The first page as it was last fetched for the signed-in user, read from
  /// the device — or null when there isn't one. Never touches the network and
  /// never fails: a missing or unreadable cache just means no head start.
  ///
  /// Carries no badge celebrations; those only ever come from the network.
  Future<FeedPageEntity?> getCachedFirstPage();

  /// Forgets the cached first page. Called on sign-out.
  Future<void> clearCache();
}
