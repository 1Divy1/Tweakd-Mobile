import 'package:dartz/dartz.dart';

import 'package:car_social_media_app/core/error/base_failures.dart';

import '../entities/tagged_item.dart';

abstract class TagsRepository {
  /// The signed-in user's own tags feed (`GET /tags/me`).
  Future<Either<Failure, TaggedItemPageEntity>> getMyTags({
    String? cursor,
    int size,
  });

  /// Another user's tags feed (`GET /tags/by-username/{username}`).
  Future<Either<Failure, TaggedItemPageEntity>> getTagsByUsername(
    String username, {
    String? cursor,
    int size,
  });

  /// Untags the signed-in user from a piece of content. A hard delete for
  /// everyone — not a personal hide — and idempotent.
  Future<Either<Failure, void>> removeTag(TaggedItemKind kind, String targetId);
}
