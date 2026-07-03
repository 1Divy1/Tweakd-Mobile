import 'package:equatable/equatable.dart';

/// Author of a thread or reply. Threads/replies that were deleted (or whose
/// profile is gone) carry a null author and render a "[deleted]" placeholder.
class ForumAuthorEntity extends Equatable {
  final String id;
  final String username;
  final String? avatarUrl;

  const ForumAuthorEntity({
    required this.id,
    required this.username,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, username, avatarUrl];
}
