import 'package:equatable/equatable.dart';

import 'package:tweakd/features/garage/domain/entities/car_summary.dart';

import 'forum_author.dart';

/// Order for a reply list (the Oldest / Newest toggle). The backend defaults
/// to oldest-first; an unknown value is a 400.
enum ForumReplySort { oldest, newest }

/// Wire value for the replies `sort` query parameter.
extension ForumReplySortApi on ForumReplySort {
  String get apiValue => switch (this) {
        ForumReplySort.oldest => 'old',
        ForumReplySort.newest => 'new',
      };
}

/// A reply ("post") in a thread. Replies load level by level: [replyCount] is
/// the number of direct children, fetched on demand. A [deleted] reply has a
/// null author/content and renders a "[deleted]" placeholder — it stays
/// expandable but can't be liked, replied to, or edited.
class ForumReplyEntity extends Equatable {
  final String id;
  final ForumAuthorEntity? author;
  final String? content;
  final int likesCount;
  final int replyCount;
  final bool deleted;
  final bool viewerHasLiked;

  /// True when this reply's author is the thread's original poster. Always
  /// false on a [deleted] reply.
  final bool isAuthor;
  final DateTime createdAt;

  /// People tagged in this reply. Soft-deleted replies come back with empty
  /// tag lists.
  final List<ForumAuthorEntity> taggedPeople;

  /// Cars tagged in this reply (garage car summaries, owner included).
  final List<CarSummaryEntity> taggedCars;

  const ForumReplyEntity({
    required this.id,
    this.author,
    this.content,
    this.likesCount = 0,
    this.replyCount = 0,
    this.deleted = false,
    this.viewerHasLiked = false,
    this.isAuthor = false,
    required this.createdAt,
    this.taggedPeople = const [],
    this.taggedCars = const [],
  });

  ForumReplyEntity copyWith({
    String? content,
    int? likesCount,
    int? replyCount,
    bool? viewerHasLiked,
    List<ForumAuthorEntity>? taggedPeople,
    List<CarSummaryEntity>? taggedCars,
  }) {
    return ForumReplyEntity(
      id: id,
      author: author,
      content: content ?? this.content,
      likesCount: likesCount ?? this.likesCount,
      replyCount: replyCount ?? this.replyCount,
      deleted: deleted,
      viewerHasLiked: viewerHasLiked ?? this.viewerHasLiked,
      isAuthor: isAuthor,
      createdAt: createdAt,
      taggedPeople: taggedPeople ?? this.taggedPeople,
      taggedCars: taggedCars ?? this.taggedCars,
    );
  }

  @override
  List<Object?> get props => [
        id,
        author,
        content,
        likesCount,
        replyCount,
        deleted,
        viewerHasLiked,
        isAuthor,
        createdAt,
        taggedPeople,
        taggedCars,
      ];
}
