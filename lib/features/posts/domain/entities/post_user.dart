import 'package:equatable/equatable.dart';

/// A minimal user reference used across the posts feature for a post's author,
/// tagged people, comment authors and post likers — all share the same shape.
class PostUserEntity extends Equatable {
  final String id;
  final String username;
  final String? avatarUrl;

  const PostUserEntity({
    required this.id,
    required this.username,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, username, avatarUrl];
}
