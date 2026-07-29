import 'package:equatable/equatable.dart';

import 'package:car_social_media_app/features/garage/domain/entities/reference_data.dart';

import 'forum_filter.dart';
import 'forum_topic.dart';

/// A pinned filter on the forums home ("your paddock"). Always car-rooted:
/// [brand] is set (plus [model] for a model shortcut), with [topic] as an
/// optional refinement. The filter itself is immutable on the backend
/// (delete + recreate to change it).
class ForumShortcutEntity extends Equatable {
  final String id;
  final String name;
  final CarBrandEntity? brand;
  final CarModelEntity? model;
  final ForumTopicEntity? topic;
  final int sortOrder;
  final bool notify;

  /// Threads matching the shortcut's filter, created after it was saved, that
  /// the viewer hasn't opened yet. Drives the unread badge on the card.
  final int unreadCount;
  final DateTime? createdAt;

  const ForumShortcutEntity({
    required this.id,
    required this.name,
    this.brand,
    this.model,
    this.topic,
    this.sortOrder = 0,
    this.notify = false,
    this.unreadCount = 0,
    this.createdAt,
  });

  ForumFilter get filter =>
      ForumFilter(brand: brand, model: model, topic: topic);

  /// Topic-only shortcuts are a leftover of the old topic hubs — there is no
  /// endpoint to open them any more, so they are dropped on the way in.
  bool get isCarRooted => brand != null || model != null;

  @override
  List<Object?> get props =>
      [id, name, brand, model, topic, sortOrder, notify, unreadCount, createdAt];
}
