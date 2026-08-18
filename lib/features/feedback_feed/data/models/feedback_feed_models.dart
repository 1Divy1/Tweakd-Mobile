import '../../domain/entities/feedback_message.dart';
import '../../domain/entities/feedback_option.dart';

/// An `{ id, label }` pair — a message's category or its roadmap status.
class FeedbackOptionModel {
  final String id;
  final String label;

  const FeedbackOptionModel({required this.id, required this.label});

  factory FeedbackOptionModel.fromJson(Map<String, dynamic> json) {
    return FeedbackOptionModel(
      id: json['id'] as String,
      label: json['label'] as String? ?? '',
    );
  }

  FeedbackOptionEntity toEntity() =>
      FeedbackOptionEntity(id: id, label: label);
}

class FeedbackAuthorModel {
  final String id;
  final String name;
  final String username;
  final String? avatarUrl;

  const FeedbackAuthorModel({
    required this.id,
    required this.name,
    required this.username,
    this.avatarUrl,
  });

  factory FeedbackAuthorModel.fromJson(Map<String, dynamic> json) {
    return FeedbackAuthorModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      username: json['username'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  FeedbackAuthorEntity toEntity() => FeedbackAuthorEntity(
        id: id,
        name: name,
        username: username,
        avatarUrl: avatarUrl,
      );
}

class FeedbackMessageModel {
  final String id;
  final FeedbackAuthorModel author;
  final String message;
  final FeedbackOptionModel type;
  final FeedbackOptionModel status;
  final String? staffResponse;
  final int upVotes;
  final int downVotes;
  final int netVotes;
  final int? myVote;
  final bool viewerIsAuthor;
  final bool deleted;
  final DateTime createdAt;
  final DateTime? completedAt;

  const FeedbackMessageModel({
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

  factory FeedbackMessageModel.fromJson(Map<String, dynamic> json) {
    final upVotes = _toInt(json['up_votes']);
    final downVotes = _toInt(json['down_votes']);

    return FeedbackMessageModel(
      id: json['id'] as String,
      author: FeedbackAuthorModel.fromJson(
        (json['author'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      message: json['message'] as String? ?? '',
      type: FeedbackOptionModel.fromJson(
        (json['type'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      status: FeedbackOptionModel.fromJson(
        (json['status'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      staffResponse: json['staff_response'] as String?,
      upVotes: upVotes,
      downVotes: downVotes,
      // Trust the server's net score, but fall back to the difference if the
      // field is missing.
      netVotes: json['net_votes'] == null
          ? upVotes - downVotes
          : _toInt(json['net_votes']),
      myVote: _toVote(json['my_vote']),
      viewerIsAuthor: json['viewer_is_author'] as bool? ?? false,
      deleted: json['deleted'] as bool? ?? false,
      createdAt: _toDate(json['created_at']) ?? DateTime.now(),
      completedAt: _toDate(json['completed_at']),
    );
  }

  FeedbackMessageEntity toEntity() => FeedbackMessageEntity(
        id: id,
        author: author.toEntity(),
        message: message,
        type: type.toEntity(),
        status: status.toEntity(),
        staffResponse: staffResponse,
        upVotes: upVotes,
        downVotes: downVotes,
        netVotes: netVotes,
        myVote: myVote,
        viewerIsAuthor: viewerIsAuthor,
        deleted: deleted,
        createdAt: createdAt,
        completedAt: completedAt,
      );
}

/// A cursor-paginated page of messages — the shape of both `GET /` and
/// `GET /completed`.
class FeedbackMessagePageModel {
  final List<FeedbackMessageModel> items;
  final String? nextCursor;

  const FeedbackMessagePageModel({required this.items, required this.nextCursor});

  factory FeedbackMessagePageModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List? ?? const [];
    return FeedbackMessagePageModel(
      items: rawItems
          .whereType<Map>()
          .map((e) => FeedbackMessageModel.fromJson(e.cast<String, dynamic>()))
          .toList(),
      nextCursor: json['next_cursor'] as String?,
    );
  }

  /// Deleted messages never reach the UI. Deletes are hard, so this only fires
  /// defensively if the backend ever soft-deletes instead.
  FeedbackMessagePageEntity toEntity() => FeedbackMessagePageEntity(
        items: [
          for (final item in items)
            if (!item.deleted) item.toEntity(),
        ],
        nextCursor: nextCursor,
      );
}

int _toInt(Object? value) => switch (value) {
      num n => n.toInt(),
      String s => int.tryParse(s) ?? 0,
      _ => 0,
    };

/// `my_vote` is documented as `1 | -1 | null`, which leaves the wire type
/// ambiguous — accept a number or a numeric string, and normalise anything
/// unexpected to "no vote".
int? _toVote(Object? value) {
  final parsed = switch (value) {
    num n => n.toInt(),
    String s => int.tryParse(s),
    _ => null,
  };
  return (parsed == 1 || parsed == -1) ? parsed : null;
}

DateTime? _toDate(Object? value) {
  if (value is! String || value.isEmpty) return null;
  // Instants arrive in UTC (ISO-8601); render them in the device's zone.
  return DateTime.tryParse(value)?.toLocal();
}
