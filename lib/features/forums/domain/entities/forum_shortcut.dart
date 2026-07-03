import 'package:equatable/equatable.dart';

import 'package:car_social_media_app/features/garage/domain/entities/reference_data.dart';

import 'forum_filter.dart';
import 'forum_topic.dart';

/// A pinned filter on the forums home ("your paddock"). At least one of
/// [brand] / [model] / [topic] is set; the filter itself is immutable on the
/// backend (delete + recreate to change it).
class ForumShortcutEntity extends Equatable {
  final String id;
  final String name;
  final CarBrandEntity? brand;
  final CarModelEntity? model;
  final ForumTopicEntity? topic;
  final int sortOrder;
  final bool notify;
  final DateTime? createdAt;

  const ForumShortcutEntity({
    required this.id,
    required this.name,
    this.brand,
    this.model,
    this.topic,
    this.sortOrder = 0,
    this.notify = false,
    this.createdAt,
  });

  ForumFilter get filter =>
      ForumFilter(brand: brand, model: model, topic: topic);

  @override
  List<Object?> get props =>
      [id, name, brand, model, topic, sortOrder, notify, createdAt];
}
