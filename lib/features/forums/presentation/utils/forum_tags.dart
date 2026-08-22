import 'package:tweakd/core/shared/entities/tag_selection.dart';
import 'package:tweakd/features/garage/domain/entities/car_summary.dart';

import '../../domain/entities/forum_author.dart';

// The tag limit and the owner-removal rule are app-wide (posts, comments,
// forums), so they live with the shared selection models.
export 'package:tweakd/core/shared/entities/tag_selection.dart'
    show kTagSelectionLimit, tagCarsWithoutOwner;

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
