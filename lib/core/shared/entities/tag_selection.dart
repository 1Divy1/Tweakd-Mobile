// Selection models shared by every "tag people & their cars" composer
// (create/edit post, new forum thread, forum replies, post comments). They are
// UI-side selections, not wire models — only the ids are ever sent.

/// Per-list cap the backend enforces on `tagged_people` / `tagged_cars`.
const int kTagSelectionLimit = 30;

/// A person tagged in a post/thread/reply, surfaced as a chip in composers.
class TaggedPerson {
  final String id;
  final String username;
  final String? avatarUrl;

  const TaggedPerson({
    required this.id,
    required this.username,
    this.avatarUrl,
  });
}

/// A car linked to a post/thread/reply. [ownerId] is the person who owns it —
/// kept so the car can be dropped when its owner is untagged, since the backend
/// rejects a car whose owner isn't also tagged (the author's own cars are
/// exempt, and carry [isOwn]).
class TaggedCar {
  final String id;
  final String name;
  final String ownerId;
  final String ownerHandle;
  final String? imageUrl;

  /// True when the car comes from the viewer's own garage. Those stay tagged
  /// even though the viewer never appears in the tagged-people list.
  final bool isOwn;

  const TaggedCar({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.ownerHandle,
    this.imageUrl,
    this.isOwn = false,
  });
}

/// Drops the cars that belonged to an untagged person — the backend rejects a
/// car whose owner isn't tagged, own cars excepted.
List<TaggedCar> tagCarsWithoutOwner(List<TaggedCar> cars, String ownerId) {
  return [
    for (final c in cars)
      if (c.isOwn || c.ownerId != ownerId) c,
  ];
}
