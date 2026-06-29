import 'package:equatable/equatable.dart';

import '../../../domain/entities/post.dart';
import '../../utils/post_error_mapper.dart';

sealed class PostDetailState extends Equatable {
  const PostDetailState();

  @override
  List<Object?> get props => [];
}

class PostDetailLoading extends PostDetailState {
  const PostDetailLoading();
}

class PostDetailLoaded extends PostDetailState {
  final PostEntity post;
  final bool isDeleting;

  const PostDetailLoaded({required this.post, this.isDeleting = false});

  PostDetailLoaded copyWith({PostEntity? post, bool? isDeleting}) {
    return PostDetailLoaded(
      post: post ?? this.post,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }

  @override
  List<Object?> get props => [post, isDeleting];
}

class PostDetailError extends PostDetailState {
  final PostErrorCode code;
  const PostDetailError(this.code);

  @override
  List<Object?> get props => [code];
}

/// Terminal state after a successful delete — the page pops on this.
class PostDetailDeleted extends PostDetailState {
  const PostDetailDeleted();
}
