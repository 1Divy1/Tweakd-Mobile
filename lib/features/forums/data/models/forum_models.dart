import 'package:car_social_media_app/features/garage/data/models/car_summary_model.dart';
import 'package:car_social_media_app/features/garage/domain/entities/car_summary.dart';
import 'package:car_social_media_app/features/garage/domain/entities/reference_data.dart';

import '../../domain/entities/forum_author.dart';
import '../../domain/entities/forum_pages.dart';
import '../../domain/entities/forum_reply.dart';
import '../../domain/entities/forum_shortcut.dart';
import '../../domain/entities/forum_suggestion.dart';
import '../../domain/entities/forum_thread.dart';
import '../../domain/entities/forum_topic.dart';

/// Wire models for `/forums/*`. All JSON keys are snake_case (the backend is
/// snake_case everywhere; camelCase in API docs is illustrative only).

class ForumTopicModel {
  final String id;
  final String name;
  final int sortOrder;
  final String? color;
  final int? threadCount;

  const ForumTopicModel({
    required this.id,
    required this.name,
    required this.sortOrder,
    this.color,
    this.threadCount,
  });

  factory ForumTopicModel.fromJson(Map<String, dynamic> json) {
    return ForumTopicModel(
      id: json['id'] as String,
      name: json['name'] as String,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      color: json['color'] as String?,
      threadCount: (json['thread_count'] as num?)?.toInt(),
    );
  }

  ForumTopicEntity toEntity() => ForumTopicEntity(
        id: id,
        name: name,
        sortOrder: sortOrder,
        color: color,
        threadCount: threadCount,
      );
}

class ForumAuthorModel {
  final String id;
  final String username;
  final String? avatarUrl;

  const ForumAuthorModel({
    required this.id,
    required this.username,
    this.avatarUrl,
  });

  factory ForumAuthorModel.fromJson(Map<String, dynamic> json) {
    return ForumAuthorModel(
      id: json['id'] as String,
      username: json['username'] as String,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  ForumAuthorEntity toEntity() =>
      ForumAuthorEntity(id: id, username: username, avatarUrl: avatarUrl);
}

/// `{id, name, thread_count?}` brand reference — parsed straight into the
/// garage entity that the whole car catalog already uses.
CarBrandEntity forumBrandFromJson(Map<String, dynamic> json) {
  return CarBrandEntity(
    id: json['id'] as String,
    name: json['name'] as String,
    threadCount: (json['thread_count'] as num?)?.toInt(),
  );
}

/// `tagged_people` — `[{id, username, avatar_url}]`, the author shape reused.
List<ForumAuthorEntity> forumTaggedPeopleFromJson(dynamic json) {
  return ((json as List<dynamic>?) ?? const [])
      .map((e) =>
          ForumAuthorModel.fromJson(e as Map<String, dynamic>).toEntity())
      .toList();
}

/// `tagged_cars` — the backend sends the garage car summary shape
/// (`{id, brand, model, cover_image, status, owner}`), so it is parsed with the
/// garage's own model instead of a forum-local copy.
List<CarSummaryEntity> forumTaggedCarsFromJson(dynamic json) {
  return ((json as List<dynamic>?) ?? const [])
      .map((e) => CarSummaryModel.fromJson(e as Map<String, dynamic>).toEntity())
      .toList();
}

/// `{id, brand_id, model, thread_count?}` model reference.
CarModelEntity forumModelFromJson(Map<String, dynamic> json) {
  return CarModelEntity(
    id: json['id'] as String,
    brandId: json['brand_id'] as String,
    model: json['model'] as String,
    threadCount: (json['thread_count'] as num?)?.toInt(),
  );
}

class ForumThreadModel {
  final ForumThreadEntity entity;

  const ForumThreadModel(this.entity);

  factory ForumThreadModel.fromJson(Map<String, dynamic> json) {
    return ForumThreadModel(ForumThreadEntity(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] == null
          ? null
          : ForumAuthorModel.fromJson(json['author'] as Map<String, dynamic>)
              .toEntity(),
      brand: json['brand'] == null
          ? null
          : forumBrandFromJson(json['brand'] as Map<String, dynamic>),
      model: json['model'] == null
          ? null
          : forumModelFromJson(json['model'] as Map<String, dynamic>),
      topics: ((json['topics'] as List<dynamic>?) ?? const [])
          .map((e) =>
              ForumTopicModel.fromJson(e as Map<String, dynamic>).toEntity())
          .toList(),
      likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
      replyCount: (json['reply_count'] as num?)?.toInt() ?? 0,
      lastActivityAt: DateTime.parse(json['last_activity_at'] as String),
      pinned: json['pinned'] as bool? ?? false,
      locked: json['locked'] as bool? ?? false,
      deleted: json['deleted'] as bool? ?? false,
      viewerHasSaved: json['viewer_has_saved'] as bool? ?? false,
      taggedPeople: forumTaggedPeopleFromJson(json['tagged_people']),
      taggedCars: forumTaggedCarsFromJson(json['tagged_cars']),
    ));
  }

  ForumThreadEntity toEntity() => entity;
}

class ForumThreadDetailModel {
  final ForumThreadDetailEntity entity;

  const ForumThreadDetailModel(this.entity);

  factory ForumThreadDetailModel.fromJson(Map<String, dynamic> json) {
    final card = ForumThreadModel.fromJson(json).toEntity();
    return ForumThreadDetailModel(ForumThreadDetailEntity(
      id: card.id,
      title: card.title,
      author: card.author,
      brand: card.brand,
      model: card.model,
      topics: card.topics,
      likesCount: card.likesCount,
      replyCount: card.replyCount,
      lastActivityAt: card.lastActivityAt,
      pinned: card.pinned,
      locked: card.locked,
      deleted: card.deleted,
      viewerHasSaved: card.viewerHasSaved,
      taggedPeople: card.taggedPeople,
      taggedCars: card.taggedCars,
      content: json['content'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      viewerHasLiked: json['viewer_has_liked'] as bool? ?? false,
    ));
  }

  ForumThreadDetailEntity toEntity() => entity;
}

class ForumReplyModel {
  final ForumReplyEntity entity;

  const ForumReplyModel(this.entity);

  factory ForumReplyModel.fromJson(Map<String, dynamic> json) {
    return ForumReplyModel(ForumReplyEntity(
      id: json['id'] as String,
      author: json['author'] == null
          ? null
          : ForumAuthorModel.fromJson(json['author'] as Map<String, dynamic>)
              .toEntity(),
      content: json['content'] as String?,
      likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
      replyCount: (json['reply_count'] as num?)?.toInt() ?? 0,
      deleted: json['deleted'] as bool? ?? false,
      viewerHasLiked: json['viewer_has_liked'] as bool? ?? false,
      isAuthor: json['is_author'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      taggedPeople: forumTaggedPeopleFromJson(json['tagged_people']),
      taggedCars: forumTaggedCarsFromJson(json['tagged_cars']),
    ));
  }

  ForumReplyEntity toEntity() => entity;
}

class ForumThreadPageModel {
  final List<ForumThreadModel> items;
  final String? nextCursor;

  const ForumThreadPageModel({required this.items, this.nextCursor});

  factory ForumThreadPageModel.fromJson(Map<String, dynamic> json) {
    return ForumThreadPageModel(
      items: ((json['items'] as List<dynamic>?) ?? const [])
          .map((e) => ForumThreadModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: json['next_cursor'] as String?,
    );
  }

  ForumThreadPageEntity toEntity() => ForumThreadPageEntity(
        items: items.map((m) => m.toEntity()).toList(),
        nextCursor: nextCursor,
      );
}

class ForumReplyPageModel {
  final List<ForumReplyModel> items;
  final String? nextCursor;

  const ForumReplyPageModel({required this.items, this.nextCursor});

  factory ForumReplyPageModel.fromJson(Map<String, dynamic> json) {
    return ForumReplyPageModel(
      items: ((json['items'] as List<dynamic>?) ?? const [])
          .map((e) => ForumReplyModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: json['next_cursor'] as String?,
    );
  }

  ForumReplyPageEntity toEntity() => ForumReplyPageEntity(
        items: items.map((m) => m.toEntity()).toList(),
        nextCursor: nextCursor,
      );
}

class ForumShortcutModel {
  final ForumShortcutEntity entity;

  const ForumShortcutModel(this.entity);

  factory ForumShortcutModel.fromJson(Map<String, dynamic> json) {
    return ForumShortcutModel(ForumShortcutEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      brand: json['brand'] == null
          ? null
          : forumBrandFromJson(json['brand'] as Map<String, dynamic>),
      model: json['model'] == null
          ? null
          : forumModelFromJson(json['model'] as Map<String, dynamic>),
      topic: json['topic'] == null
          ? null
          : ForumTopicModel.fromJson(json['topic'] as Map<String, dynamic>)
              .toEntity(),
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      notify: json['notify'] as bool? ?? false,
      unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    ));
  }

  ForumShortcutEntity toEntity() => entity;
}

class ForumSuggestionModel {
  final ForumSuggestionEntity entity;

  const ForumSuggestionModel(this.entity);

  factory ForumSuggestionModel.fromJson(Map<String, dynamic> json) {
    return ForumSuggestionModel(ForumSuggestionEntity(
      type: _suggestionTypeFromJson(json['type'] as String?),
      id: json['id'] as String,
      name: json['name'] as String,
      subtitle: json['subtitle'] as String?,
      threadCount: (json['thread_count'] as num?)?.toInt() ?? 0,
    ));
  }

  ForumSuggestionEntity toEntity() => entity;

  /// Only "brand" and "model" are issued now; anything else falls back to a
  /// brand suggestion.
  static ForumSuggestionType _suggestionTypeFromJson(String? value) =>
      value == 'model' ? ForumSuggestionType.model : ForumSuggestionType.brand;
}
