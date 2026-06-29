import 'package:equatable/equatable.dart';

sealed class CreatePostEvent extends Equatable {
  const CreatePostEvent();

  @override
  List<Object?> get props => [];
}

/// Creates the post (text), then uploads its images and commits their keys.
/// [photoPaths] are local file paths in display order (index 0 = cover).
class SubmitPost extends CreatePostEvent {
  final String? description;
  final List<String> photoPaths;
  final List<String> taggedPeopleIds;
  final List<String> taggedCarIds;
  final bool likesCountEnabled;
  final bool commentsCountEnabled;
  final bool sharesCountEnabled;
  final bool savedCountEnabled;

  const SubmitPost({
    required this.description,
    required this.photoPaths,
    required this.taggedPeopleIds,
    required this.taggedCarIds,
    required this.likesCountEnabled,
    required this.commentsCountEnabled,
    required this.sharesCountEnabled,
    required this.savedCountEnabled,
  });

  @override
  List<Object?> get props => [
        description,
        photoPaths,
        taggedPeopleIds,
        taggedCarIds,
        likesCountEnabled,
        commentsCountEnabled,
        sharesCountEnabled,
        savedCountEnabled,
      ];
}
