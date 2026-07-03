import 'package:equatable/equatable.dart';

import 'package:car_social_media_app/features/garage/domain/entities/reference_data.dart';

import 'forum_topic.dart';

/// A hub filter: a car (brand and optionally model), a topic, or both.
/// Shortcuts on the forums home are saved filters. When [model] is set,
/// [brand] is set too (brand is derived from the model).
class ForumFilter extends Equatable {
  final CarBrandEntity? brand;
  final CarModelEntity? model;
  final ForumTopicEntity? topic;

  const ForumFilter({this.brand, this.model, this.topic});

  /// A filter narrowed beyond a whole brand (a model and/or a topic). Refined
  /// hubs get the "Save shortcut" affordance.
  bool get isRefined => model != null || topic != null;

  bool get isEmpty => brand == null && model == null && topic == null;

  /// The hub page headline: the most specific car selection, else the topic.
  String get title => model?.model ?? brand?.name ?? topic?.name ?? '';

  /// Suggested shortcut name, e.g. "M4 · Tuning".
  String get defaultShortcutName => [
        model?.model ?? brand?.name,
        topic?.name,
      ].whereType<String>().join(' · ');

  ForumFilter withModel(CarModelEntity? model) =>
      ForumFilter(brand: brand, model: model, topic: topic);

  ForumFilter withTopic(ForumTopicEntity? topic) =>
      ForumFilter(brand: brand, model: model, topic: topic);

  @override
  List<Object?> get props => [brand, model, topic];
}
