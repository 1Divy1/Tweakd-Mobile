import 'package:equatable/equatable.dart';

/// What a popular-hub suggestion points at. Drives navigation and which id
/// field is sent when the suggestion is pinned as a shortcut.
enum ForumSuggestionType { brand, model, topic }

/// One entry from `GET /forums/suggestions`: the most active brands, models and
/// topics, merged and ranked by thread count. [subtitle] carries a model's
/// brand (so "M4" reads "BMW M4"); it's null for brands and topics.
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

  /// Display label, e.g. "BMW M4" for a model, "BMW" / "Engine" otherwise.
  String get displayName =>
      subtitle != null && subtitle!.isNotEmpty ? '$subtitle $name' : name;

  @override
  List<Object?> get props => [type, id, name, subtitle, threadCount];
}
