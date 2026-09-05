import '../../../badges/data/models/user_badge_model.dart';
import '../../../posts/data/models/post_models.dart';
import '../../domain/entities/feed_page.dart';

/// Wire model for `GET /feed/global`.
///
/// The body is `PostPageDto` byte-for-byte (`items`, `next_cursor`) plus one
/// added key, `pending_badge_celebrations` — a `UserBadgeDto[]` that is always
/// present, never null, oldest unlock first, and empty on any paged
/// (`?cursor=`) request. Post parsing is delegated to [PostPageModel] so the
/// posts feature stays the single owner of that shape.
class FeedPageModel {
  final PostPageModel page;
  final List<UserBadgeModel> pendingBadgeCelebrations;

  const FeedPageModel({
    required this.page,
    this.pendingBadgeCelebrations = const [],
  });

  factory FeedPageModel.fromJson(Map<String, dynamic> json) {
    final raw =
        json['pending_badge_celebrations'] as List<dynamic>? ?? const [];
    return FeedPageModel(
      page: PostPageModel.fromJson(json),
      pendingBadgeCelebrations: raw
          .map((e) => UserBadgeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  FeedPageEntity toEntity() => FeedPageEntity(
    items: page.items.map((p) => p.toEntity()).toList(),
    nextCursor: page.nextCursor,
    pendingBadgeCelebrations: pendingBadgeCelebrations
        .map((b) => b.toEntity())
        .toList(),
  );
}
