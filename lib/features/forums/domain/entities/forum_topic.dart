import 'package:equatable/equatable.dart';

/// Whether a topic describes a car component (Engine, Suspension, …) or a
/// thread format (Tuning, Buy / Sell, Help, …). Mirrors the two groups on the
/// browse page and in the new-thread composer.
enum ForumTopicKind { component, format }

/// A forum topic. [id] is a slug (e.g. "tuning"), not a UUID.
class ForumTopicEntity extends Equatable {
  final String id;
  final String name;
  final ForumTopicKind kind;
  final int sortOrder;
  final String? color;

  /// Not returned by the backend yet — rendered only when present.
  final int? threadCount;

  const ForumTopicEntity({
    required this.id,
    required this.name,
    required this.kind,
    this.sortOrder = 0,
    this.color,
    this.threadCount,
  });

  @override
  List<Object?> get props => [id, name, kind, sortOrder, color, threadCount];
}

/// One group of the `GET /forums/topics` response.
class ForumTopicGroupEntity extends Equatable {
  final ForumTopicKind kind;
  final List<ForumTopicEntity> topics;

  const ForumTopicGroupEntity({required this.kind, required this.topics});

  @override
  List<Object?> get props => [kind, topics];
}
