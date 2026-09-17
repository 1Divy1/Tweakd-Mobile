import '../../domain/entities/post_reposted_by.dart';
import '../../domain/entities/post.dart';
import '../../domain/entities/post_image.dart';
import '../../domain/entities/post_pages.dart';
import '../../domain/entities/post_tagged_car.dart';
import '../../domain/entities/post_user.dart';
import 'package:tweakd/features/map_events/data/models/participant_card_model.dart';

/// A minimal user reference: post author, tagged person, comment author, liker.
class PostUserModel {
  final String id;
  final String username;
  final String? avatarUrl;

  const PostUserModel({
    required this.id,
    required this.username,
    this.avatarUrl,
  });

  factory PostUserModel.fromJson(Map<String, dynamic> json) {
    return PostUserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  PostUserEntity toEntity() => PostUserEntity(
        id: id,
        username: username,
        avatarUrl: avatarUrl,
      );
}

class PostImageModel {
  final String id;
  final String imageUrl;
  final int displayOrder;

  const PostImageModel({
    required this.id,
    required this.imageUrl,
    required this.displayOrder,
  });

  factory PostImageModel.fromJson(Map<String, dynamic> json) {
    return PostImageModel(
      id: json['id'] as String,
      imageUrl: json['image_url'] as String,
      displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
    );
  }

  PostImageEntity toEntity() => PostImageEntity(
        id: id,
        imageUrl: imageUrl,
        displayOrder: displayOrder,
      );
}

class PostTaggedCarModel {
  final String id;
  final String make;
  final String model;
  final String? ownerId;
  final String? ownerUsername;

  const PostTaggedCarModel({
    required this.id,
    required this.make,
    required this.model,
    this.ownerId,
    this.ownerUsername,
  });

  factory PostTaggedCarModel.fromJson(Map<String, dynamic> json) {
    // Tagged cars are serialized as the backend `CarSummaryDto`, whose make
    // field is `brand`; `make` is kept as a fallback for any legacy payload.
    final owner = json['owner'] as Map<String, dynamic>?;
    return PostTaggedCarModel(
      id: json['id'] as String,
      make: (json['brand'] as String?) ?? (json['make'] as String?) ?? '',
      model: (json['model'] as String?) ?? '',
      ownerId: owner?['id'] as String?,
      ownerUsername: owner?['username'] as String?,
    );
  }

  PostTaggedCarEntity toEntity() => PostTaggedCarEntity(
        id: id,
        make: make,
        model: model,
        ownerId: ownerId,
        ownerUsername: ownerUsername,
      );
}

class PostModel {
  final String id;
  final String? description;
  final PostUserModel author;
  final List<PostImageModel> images;
  final List<PostUserModel> taggedPeople;
  final List<PostTaggedCarModel> taggedCars;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final int savedCount;
  final bool likesCountEnabled;
  final bool commentsCountEnabled;
  final bool sharesCountEnabled;
  final bool savedCountEnabled;
  final bool viewerHasLiked;
  final bool viewerHasSaved;
  final bool viewerHasReposted;
  final RepostedByModel? repostedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ParticipantCardModel? participantCard;

  const PostModel({
    required this.id,
    required this.description,
    required this.author,
    required this.images,
    required this.taggedPeople,
    required this.taggedCars,
    required this.likesCount,
    required this.commentsCount,
    required this.sharesCount,
    required this.savedCount,
    required this.likesCountEnabled,
    required this.commentsCountEnabled,
    required this.sharesCountEnabled,
    required this.savedCountEnabled,
    required this.viewerHasLiked,
    required this.viewerHasSaved,
    this.viewerHasReposted = false,
    this.repostedBy,
    required this.createdAt,
    required this.updatedAt,
    this.participantCard,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    List<T> list<T>(String key, T Function(Map<String, dynamic>) of) =>
        (json[key] as List<dynamic>? ?? [])
            .map((e) => of(e as Map<String, dynamic>))
            .toList();

    int intOf(String key) => (json[key] as num?)?.toInt() ?? 0;
    bool boolOf(String key) => json[key] as bool? ?? true;

    return PostModel(
      id: json['id'] as String,
      description: json['description'] as String?,
      author: PostUserModel.fromJson(json['author'] as Map<String, dynamic>),
      images: list('images', PostImageModel.fromJson)
        ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder)),
      taggedPeople: list('tagged_people', PostUserModel.fromJson),
      taggedCars: list('tagged_cars', PostTaggedCarModel.fromJson),
      likesCount: intOf('likes_count'),
      commentsCount: intOf('comments_count'),
      sharesCount: intOf('shares_count'),
      savedCount: intOf('saved_count'),
      likesCountEnabled: boolOf('likes_count_enabled'),
      commentsCountEnabled: boolOf('comments_count_enabled'),
      sharesCountEnabled: boolOf('shares_count_enabled'),
      savedCountEnabled: boolOf('saved_count_enabled'),
      viewerHasLiked: json['viewer_has_liked'] as bool? ?? false,
      viewerHasSaved: json['viewer_has_saved'] as bool? ?? false,
      viewerHasReposted: json['viewer_has_reposted'] as bool? ?? false,
      repostedBy: RepostedByModel.tryParse(json['reposted_by']),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(
          (json['updated_at'] ?? json['created_at']) as String),
      participantCard: ParticipantCardModel.tryParse(json['participant_card']),
    );
  }

  PostEntity toEntity() => PostEntity(
        id: id,
        description: description,
        author: author.toEntity(),
        images: images.map((i) => i.toEntity()).toList(),
        taggedPeople: taggedPeople.map((p) => p.toEntity()).toList(),
        taggedCars: taggedCars.map((c) => c.toEntity()).toList(),
        likesCount: likesCount,
        commentsCount: commentsCount,
        sharesCount: sharesCount,
        savedCount: savedCount,
        likesCountEnabled: likesCountEnabled,
        commentsCountEnabled: commentsCountEnabled,
        sharesCountEnabled: sharesCountEnabled,
        savedCountEnabled: savedCountEnabled,
        viewerHasLiked: viewerHasLiked,
        viewerHasSaved: viewerHasSaved,
        viewerHasReposted: viewerHasReposted,
        repostedBy: repostedBy?.toEntity(),
        createdAt: createdAt,
        updatedAt: updatedAt,
        participantCard: participantCard?.toEntity(),
      );
}

/// `reposted_by` on a feed post: up to two followed reposters, most recent
/// first, plus how many followed accounts reposted it in all.
class RepostedByModel {
  final List<PostUserModel> users;
  final int totalCount;

  const RepostedByModel({required this.users, required this.totalCount});

  /// Null when the key is absent or names nobody — the post then shows no
  /// "reposted" line.
  static RepostedByModel? tryParse(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    final users = (json['users'] as List<dynamic>? ?? [])
        .map((e) => PostUserModel.fromJson(e as Map<String, dynamic>))
        .toList();
    if (users.isEmpty) return null;
    final total = (json['total_count'] as num?)?.toInt() ?? 0;
    return RepostedByModel(
      users: users,
      totalCount: total < users.length ? users.length : total,
    );
  }

  RepostedByEntity toEntity() => RepostedByEntity(
        users: users.map((u) => u.toEntity()).toList(),
        totalCount: totalCount,
      );
}

/// Cursor-paginated page of posts (GET /posts/me, /posts/by-username/{u}, /posts/by-username/{u}/reposts).
class PostPageModel {
  final List<PostModel> items;
  final String? nextCursor;

  const PostPageModel({required this.items, required this.nextCursor});

  factory PostPageModel.fromJson(Map<String, dynamic> json) {
    return PostPageModel(
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => PostModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: json['next_cursor'] as String?,
    );
  }

  PostPageEntity toEntity() => PostPageEntity(
        items: items.map((p) => p.toEntity()).toList(),
        nextCursor: nextCursor,
      );
}
