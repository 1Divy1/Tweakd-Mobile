import 'package:tweakd/core/error/base_failures.dart';

/// The requested post does not exist (404).
class PostNotFoundFailure extends Failure {
  const PostNotFoundFailure() : super(message: 'Post not found.');
}

/// The signed-in user is not the post's owner and cannot modify it (403).
class NotPostOwnerFailure extends Failure {
  const NotPostOwnerFailure() : super(message: 'You do not own this post.');
}

/// A tagging constraint was violated — e.g. a car was tagged without tagging its
/// owner (400).
class InvalidTagFailure extends Failure {
  const InvalidTagFailure([String message = 'Invalid tags.'])
      : super(message: message);
}
