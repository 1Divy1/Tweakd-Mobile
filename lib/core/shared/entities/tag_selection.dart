// Selection models shared by every "tag people & their cars" composer
// (create/edit post, new forum thread, forum replies). They are UI-side
// selections, not wire models — only the ids are ever sent.

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
