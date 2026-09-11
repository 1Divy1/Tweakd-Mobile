import 'package:equatable/equatable.dart';

import 'post_image.dart';
import 'package:tweakd/features/map_events/domain/entities/participant_card.dart';
import 'post_tagged_car.dart';
import 'post_user.dart';

/// A full post as returned by the backend. Engagement counters are always
/// present; the matching `*CountEnabled` flag reflects the author's choice to
/// show or hide that number — the UI honours the flag, the count stays valid.
class PostEntity extends Equatable {
  final String id;
  final String? description;
  final PostUserEntity author;
  final List<PostImageEntity> images;
  final List<PostUserEntity> taggedPeople;
  final List<PostTaggedCarEntity> taggedCars;

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

  /// The participant card this post shares, drawn in place of images. Null on
  /// every ordinary post.
  final ParticipantCardEntity? participantCard;

  const PostEntity({
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
    this.participantCard,
  });

  PostEntity copyWith({
    String? description,
    List<PostImageEntity>? images,
    List<PostUserEntity>? taggedPeople,
    List<PostTaggedCarEntity>? taggedCars,
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    int? savedCount,
    bool? likesCountEnabled,
    bool? commentsCountEnabled,
    bool? sharesCountEnabled,
    bool? savedCountEnabled,
    bool? viewerHasLiked,
    bool? viewerHasSaved,
    DateTime? updatedAt,
  }) {
    return PostEntity(
      id: id,
      description: description ?? this.description,
      author: author,
      images: images ?? this.images,
      taggedPeople: taggedPeople ?? this.taggedPeople,
      taggedCars: taggedCars ?? this.taggedCars,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      savedCount: savedCount ?? this.savedCount,
      likesCountEnabled: likesCountEnabled ?? this.likesCountEnabled,
      commentsCountEnabled: commentsCountEnabled ?? this.commentsCountEnabled,
      sharesCountEnabled: sharesCountEnabled ?? this.sharesCountEnabled,
      savedCountEnabled: savedCountEnabled ?? this.savedCountEnabled,
      viewerHasLiked: viewerHasLiked ?? this.viewerHasLiked,
      viewerHasSaved: viewerHasSaved ?? this.viewerHasSaved,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      participantCard: participantCard,
    );
  }

  @override
  List<Object?> get props => [
        id,
        description,
        author,
        images,
        taggedPeople,
        taggedCars,
        likesCount,
        commentsCount,
        sharesCount,
        savedCount,
        likesCountEnabled,
        commentsCountEnabled,
        sharesCountEnabled,
        savedCountEnabled,
        viewerHasLiked,
        viewerHasSaved,
        createdAt,
        updatedAt,
        participantCard,
      ];
}
