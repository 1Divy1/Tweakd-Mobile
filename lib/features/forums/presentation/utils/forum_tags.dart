import 'package:car_social_media_app/core/shared/entities/tag_selection.dart';
import 'package:car_social_media_app/features/garage/domain/entities/car_summary.dart';

import '../../domain/entities/forum_author.dart';

/// Per-list cap the backend enforces on `tagged_people` / `tagged_cars`.
const int kForumTagLimit = 30;

/// Tagged people as the composer's selection model.
List<TaggedPerson> forumTaggedPeopleToSelection(
  List<ForumAuthorEntity> people,
) {
  return [
    for (final p in people)
      TaggedPerson(id: p.id, username: p.username, avatarUrl: p.avatarUrl),
  ];
}

/// Tagged cars as the composer's selection model. [currentUserId] marks the
/// viewer's own cars, which stay tagged without their owner being tagged.
List<TaggedCar> forumTaggedCarsToSelection(
  List<CarSummaryEntity> cars, {
  String? currentUserId,
}) {
  return [
    for (final c in cars)
      TaggedCar(
        id: c.id,
        name: '${c.brand} ${c.model}'.trim(),
        ownerId: c.ownerId ?? '',
        ownerHandle: c.ownerUsername ?? '',
        imageUrl: c.coverImage?.url,
        isOwn: currentUserId != null && c.ownerId == currentUserId,
      ),
  ];
}

/// Drops the cars that belonged to an untagged person — the backend rejects a
/// car whose owner isn't tagged, own cars excepted.
List<TaggedCar> forumCarsWithoutOwner(List<TaggedCar> cars, String ownerId) {
  return [
    for (final c in cars)
      if (c.isOwn || c.ownerId != ownerId) c,
  ];
}
