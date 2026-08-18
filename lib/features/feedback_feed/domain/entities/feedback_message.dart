import 'package:equatable/equatable.dart';

import 'feedback_option.dart';

/// The author of a feedback message.
class FeedbackAuthorEntity extends Equatable {
  final String id;
  final String name;
  final String username;
  final String? avatarUrl;

  const FeedbackAuthorEntity({
    required this.id,
    required this.name,
    required this.username,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, name, username, avatarUrl];
}

/// One card on the feedback board.
///
/// [myVote] is `1` (up), `-1` (down) or null (no vote). [viewerIsAuthor] comes
/// from the backend rather than being derived client-side, so the delete
/// affordance never depends on the client knowing its own user id.
class FeedbackMessageEntity extends Equatable {
  final String id;
  final FeedbackAuthorEntity author;
  final String message;
  final FeedbackOptionEntity type;
  final FeedbackOptionEntity status;

  /// A staff reply, shown on completed cards. Null until someone answers.
  final String? staffResponse;

  final int upVotes;
  final int downVotes;
  final int netVotes;
  final int? myVote;
  final bool viewerIsAuthor;
  final bool deleted;
  final DateTime createdAt;
  final DateTime? completedAt;

  const FeedbackMessageEntity({
    required this.id,
    required this.author,
    required this.message,
    required this.type,
    required this.status,
    required this.staffResponse,
    required this.upVotes,
    required this.downVotes,
    required this.netVotes,
    required this.myVote,
    required this.viewerIsAuthor,
    required this.deleted,
    required this.createdAt,
    required this.completedAt,
  });

  /// The author may hard-delete their own message only while it is still
  /// `sent` — once staff pick it up the backend answers 409.
  bool get canDelete =>
      viewerIsAuthor && status.id == kFeedbackStatusSent;

  bool get isCompleted => status.id == kFeedbackStatusCompleted;

  /// Applies an optimistic vote locally: recomputes both tallies and the net
  /// score for [nextVote] (null = withdrawn). The real numbers arrive with the
  /// vote response and replace this.
  FeedbackMessageEntity withVote(int? nextVote) {
    var up = upVotes;
    var down = downVotes;

    // Remove the previous vote, then apply the new one.
    if (myVote == 1) up--;
    if (myVote == -1) down--;
    if (nextVote == 1) up++;
    if (nextVote == -1) down++;

    return copyWith(
      upVotes: up < 0 ? 0 : up,
      downVotes: down < 0 ? 0 : down,
      netVotes: (up < 0 ? 0 : up) - (down < 0 ? 0 : down),
      myVote: nextVote,
      clearMyVote: nextVote == null,
    );
  }

  FeedbackMessageEntity copyWith({
    int? upVotes,
    int? downVotes,
    int? netVotes,
    int? myVote,
    bool clearMyVote = false,
  }) {
    return FeedbackMessageEntity(
      id: id,
      author: author,
      message: message,
      type: type,
      status: status,
      staffResponse: staffResponse,
      upVotes: upVotes ?? this.upVotes,
      downVotes: downVotes ?? this.downVotes,
      netVotes: netVotes ?? this.netVotes,
      myVote: clearMyVote ? null : (myVote ?? this.myVote),
      viewerIsAuthor: viewerIsAuthor,
      deleted: deleted,
      createdAt: createdAt,
      completedAt: completedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        author,
        message,
        type,
        status,
        staffResponse,
        upVotes,
        downVotes,
        netVotes,
        myVote,
        viewerIsAuthor,
        deleted,
        createdAt,
        completedAt,
      ];
}

/// A cursor-paginated slice of the board. [nextCursor] is opaque and echoed
/// back as `?cursor=`; null means the last page.
class FeedbackMessagePageEntity extends Equatable {
  final List<FeedbackMessageEntity> items;
  final String? nextCursor;

  const FeedbackMessagePageEntity({
    required this.items,
    required this.nextCursor,
  });

  @override
  List<Object?> get props => [items, nextCursor];
}
