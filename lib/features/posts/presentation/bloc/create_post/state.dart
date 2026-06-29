import 'package:equatable/equatable.dart';

import '../../../domain/entities/post.dart';
import '../../utils/post_error_mapper.dart';

sealed class CreatePostState extends Equatable {
  const CreatePostState();

  @override
  List<Object?> get props => [];
}

class CreatePostInitial extends CreatePostState {
  const CreatePostInitial();
}

/// The post is being published. [phase] drives the publish-button label.
class CreatePostSubmitting extends CreatePostState {
  final CreatePostPhase phase;
  const CreatePostSubmitting(this.phase);

  @override
  List<Object?> get props => [phase];
}

class CreatePostSuccess extends CreatePostState {
  final PostEntity post;
  const CreatePostSuccess(this.post);

  @override
  List<Object?> get props => [post];
}

class CreatePostError extends CreatePostState {
  final PostErrorCode code;
  const CreatePostError(this.code);

  @override
  List<Object?> get props => [code];
}
