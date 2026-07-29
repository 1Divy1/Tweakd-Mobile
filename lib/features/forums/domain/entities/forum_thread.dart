import 'package:equatable/equatable.dart';

import 'package:car_social_media_app/features/garage/domain/entities/car_summary.dart';
import 'package:car_social_media_app/features/garage/domain/entities/reference_data.dart';

import 'forum_author.dart';
import 'forum_topic.dart';

/// Sort order for thread lists (the Hot / New / Active tabs).
enum ForumThreadSort { hot, newest, active }

/// Wire value for the `sort` query parameter.
extension ForumThreadSortApi on ForumThreadSort {
  String get apiValue => switch (this) {
        ForumThreadSort.hot => 'hot',
        ForumThreadSort.newest => 'new',
        ForumThreadSort.active => 'active',
      };
}

/// A thread as it appears in lists (feed, hubs). [deleted] threads keep their
/// stats but have a null [author] and render "[deleted]".
class ForumThreadEntity extends Equatable {
  final String id;
  final String title;
  final ForumAuthorEntity? author;
  final CarBrandEntity? brand;
  final CarModelEntity? model;
  final List<ForumTopicEntity> topics;
  final int likesCount;
  final int replyCount;
  final DateTime lastActivityAt;
  final bool pinned;
  final bool locked;
  final bool deleted;

  /// Whether the viewer has saved (bookmarked) this thread. Present on every
  /// thread card and on the thread detail.
  final bool viewerHasSaved;

  /// People tagged in the OP. Anonymized threads keep their tags.
  final List<ForumAuthorEntity> taggedPeople;

  /// Cars tagged in the OP — the same summary shape the garage uses, so the
  /// owner travels with the car.
  final List<CarSummaryEntity> taggedCars;

  const ForumThreadEntity({
    required this.id,
    required this.title,
    this.author,
    this.brand,
    this.model,
    this.topics = const [],
    this.likesCount = 0,
    this.replyCount = 0,
    required this.lastActivityAt,
    this.pinned = false,
    this.locked = false,
    this.deleted = false,
    this.viewerHasSaved = false,
    this.taggedPeople = const [],
    this.taggedCars = const [],
  });

  @override
  List<Object?> get props => [
        id,
        title,
        author,
        brand,
        model,
        topics,
        likesCount,
        replyCount,
        lastActivityAt,
        pinned,
        locked,
        deleted,
        viewerHasSaved,
        taggedPeople,
        taggedCars,
      ];

  /// Returns a copy with the viewer's save state flipped — used to reflect an
  /// optimistic bookmark toggle in thread lists (feed, hubs, saved).
  ForumThreadEntity withSaved(bool saved) => ForumThreadEntity(
        id: id,
        title: title,
        author: author,
        brand: brand,
        model: model,
        topics: topics,
        likesCount: likesCount,
        replyCount: replyCount,
        lastActivityAt: lastActivityAt,
        pinned: pinned,
        locked: locked,
        deleted: deleted,
        viewerHasSaved: saved,
        taggedPeople: taggedPeople,
        taggedCars: taggedCars,
      );
}

/// Full thread as returned by `GET /forums/threads/{id}`: the card fields
/// plus the OP body and the viewer's like state.
class ForumThreadDetailEntity extends ForumThreadEntity {
  final String? content;
  final DateTime createdAt;
  final bool viewerHasLiked;

  const ForumThreadDetailEntity({
    required super.id,
    required super.title,
    super.author,
    super.brand,
    super.model,
    super.topics,
    super.likesCount,
    super.replyCount,
    required super.lastActivityAt,
    super.pinned,
    super.locked,
    super.deleted,
    super.viewerHasSaved,
    super.taggedPeople,
    super.taggedCars,
    this.content,
    required this.createdAt,
    this.viewerHasLiked = false,
  });

  ForumThreadDetailEntity copyWith({
    int? likesCount,
    int? replyCount,
    bool? viewerHasLiked,
    bool? viewerHasSaved,
    String? content,
    List<ForumAuthorEntity>? taggedPeople,
    List<CarSummaryEntity>? taggedCars,
  }) {
    return ForumThreadDetailEntity(
      id: id,
      title: title,
      author: author,
      brand: brand,
      model: model,
      topics: topics,
      likesCount: likesCount ?? this.likesCount,
      replyCount: replyCount ?? this.replyCount,
      lastActivityAt: lastActivityAt,
      pinned: pinned,
      locked: locked,
      deleted: deleted,
      viewerHasSaved: viewerHasSaved ?? this.viewerHasSaved,
      taggedPeople: taggedPeople ?? this.taggedPeople,
      taggedCars: taggedCars ?? this.taggedCars,
      content: content ?? this.content,
      createdAt: createdAt,
      viewerHasLiked: viewerHasLiked ?? this.viewerHasLiked,
    );
  }

  @override
  List<Object?> get props =>
      [...super.props, content, createdAt, viewerHasLiked];
}
