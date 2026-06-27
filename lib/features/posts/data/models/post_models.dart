import '../../domain/entities/post.dart';
import '../../domain/entities/post_image.dart';
import '../../domain/entities/post_pages.dart';
import '../../domain/entities/post_tagged_car.dart';
import '../../domain/entities/post_user.dart';

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

  const PostTaggedCarModel({
    required this.id,
    required this.make,
    required this.model,
  });

  factory PostTaggedCarModel.fromJson(Map<String, dynamic> json) {
    return PostTaggedCarModel(
      id: json['id'] as String,
      make: (json['make'] as String?) ?? '',
      model: (json['model'] as String?) ?? '',
    );
  }

  PostTaggedCarEntity toEntity() => PostTaggedCarEntity(
        id: id,
        make: make,
        model: model,
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
  final DateTime createdAt;
  final DateTime updatedAt;

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
    required this.createdAt,
    required this.updatedAt,
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
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(
          (json['updated_at'] ?? json['created_at']) as String),
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
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

/// Cursor-paginated page of posts (GET /posts/me, /posts/by-username/{u}).
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
