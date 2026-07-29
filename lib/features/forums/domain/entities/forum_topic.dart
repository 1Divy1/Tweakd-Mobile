import 'package:equatable/equatable.dart';

/// A forum topic. [id] is a slug (e.g. "tuning"), not a UUID. Topics are not
/// hubs of their own — they only refine a brand or model hub.
class ForumTopicEntity extends Equatable {
  final String id;
  final String name;
  final int sortOrder;
  final String? color;

  /// Not always returned by the backend — rendered only when present.
  final int? threadCount;

  const ForumTopicEntity({
    required this.id,
    required this.name,
    this.sortOrder = 0,
    this.color,
    this.threadCount,
  });

  @override
  List<Object?> get props => [id, name, sortOrder, color, threadCount];
}
