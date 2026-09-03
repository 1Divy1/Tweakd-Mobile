import 'package:equatable/equatable.dart';

/// One badge from the backend catalogue.
///
/// [id] is the stable code (`pioneer`, `podium`, …), not a uuid — it is what a
/// deep link or an analytics event would key on. [title] and [description] are
/// display copy owned by the backend and rendered as-is, the same contract
/// `LanguageOptionEntity` uses.
///
/// The artwork is a **remote SVG**: [unlockedUrl] and [lockedUrl] are complete
/// URLs, so nothing here builds a storage key.
class BadgeEntity extends Equatable {
  final String id;
  final String title;

  /// How to unlock it. Null for badges whose title says it all.
  final String? description;

  /// Artwork for a badge the user holds.
  final String unlockedUrl;

  /// Artwork for one they don't. Null when the badge has no locked variant, in
  /// which case the UI greys [unlockedUrl] itself.
  final String? lockedUrl;

  /// False for a retired badge. It never comes back from the catalogue, but a
  /// user who already holds one still sees it on their profile — so this is a
  /// reason to keep drawing it, not to hide it.
  final bool available;

  final DateTime? createdAt;

  const BadgeEntity({
    required this.id,
    required this.title,
    required this.unlockedUrl,
    this.description,
    this.lockedUrl,
    this.available = true,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    unlockedUrl,
    lockedUrl,
    available,
    createdAt,
  ];
}
