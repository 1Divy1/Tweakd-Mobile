import 'package:equatable/equatable.dart';

import 'package:tweakd/features/garage/domain/entities/reference_data.dart';

import 'forum_filter.dart';

/// What a popular-hub suggestion points at. Drives which hub the chip opens
/// (a brand hub, or a brand + model hub).
enum ForumSuggestionType { brand, model }

/// One entry from `GET /forums/suggestions`: the most active brands and models,
/// merged and ranked by thread count. [subtitle] carries a model's brand (so
/// "M4" reads "BMW M4"); it's null for brands.
class ForumSuggestionEntity extends Equatable {
  final ForumSuggestionType type;
  final String id;
  final String name;
  final String? subtitle;
  final int threadCount;

  const ForumSuggestionEntity({
    required this.type,
    required this.id,
    required this.name,
    this.subtitle,
    this.threadCount = 0,
  });

  /// Display label, e.g. "BMW M4" for a model, "BMW" for a brand.
  String get displayName =>
      subtitle != null && subtitle!.isNotEmpty ? '$subtitle $name' : name;

  /// The hub filter this chip opens: a brand hub, or a brand + model hub.
  ///
  /// The suggestions endpoint carries the model's owning-brand *name* (as
  /// [subtitle]) but not its id, so a model suggestion's synthetic [brand] has
  /// an empty id — it is display-only (the model hub queries by model id, and
  /// the brand id is never read for a filter with a model set).
  ForumFilter toFilter() {
    switch (type) {
      case ForumSuggestionType.brand:
        return ForumFilter(
          brand: CarBrandEntity(id: id, name: name, threadCount: threadCount),
        );
      case ForumSuggestionType.model:
        return ForumFilter(
          brand: subtitle != null && subtitle!.isNotEmpty
              ? CarBrandEntity(id: '', name: subtitle!)
              : null,
          model: CarModelEntity(
            id: id,
            brandId: '',
            model: name,
            threadCount: threadCount,
          ),
        );
    }
  }

  @override
  List<Object?> get props => [type, id, name, subtitle, threadCount];
}
