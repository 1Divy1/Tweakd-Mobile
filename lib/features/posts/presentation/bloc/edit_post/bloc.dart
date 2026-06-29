import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/post.dart';
import '../../../domain/entities/post_params.dart';
import '../../../domain/usecases/delete_post.dart';
import '../../../domain/usecases/update_post.dart';
import '../../utils/post_error_mapper.dart';

// ── Events ────────────────────────────────────────────────────────────────────

sealed class EditPostEvent extends Equatable {
  const EditPostEvent();

  @override
  List<Object?> get props => [];
}

/// Saves the post's editable fields. Images are immutable after publish, so they
/// are never part of this payload. [taggedPeople]/[taggedCars] fully replace the
/// existing sets.
class SubmitPostEdit extends EditPostEvent {
  final String postId;
  final String? description;
  final List<String> taggedPeople;
  final List<String> taggedCars;
  final bool likesCountEnabled;
  final bool commentsCountEnabled;
  final bool sharesCountEnabled;
  final bool savedCountEnabled;

  const SubmitPostEdit({
    required this.postId,
    required this.description,
    required this.taggedPeople,
    required this.taggedCars,
    required this.likesCountEnabled,
    required this.commentsCountEnabled,
    required this.sharesCountEnabled,
    required this.savedCountEnabled,
  });

  @override
  List<Object?> get props => [
        postId,
        description,
        taggedPeople,
        taggedCars,
        likesCountEnabled,
        commentsCountEnabled,
        sharesCountEnabled,
        savedCountEnabled,
      ];
}

/// Deletes the post from the edit screen.
class SubmitPostDelete extends EditPostEvent {
  final String postId;
  const SubmitPostDelete(this.postId);

  @override
  List<Object?> get props => [postId];
}

// ── State ─────────────────────────────────────────────────────────────────────

sealed class EditPostState extends Equatable {
  const EditPostState();

  @override
  List<Object?> get props => [];
}

class EditPostInitial extends EditPostState {
  const EditPostInitial();
}

class EditPostSubmitting extends EditPostState {
  const EditPostSubmitting();
}

class EditPostSuccess extends EditPostState {
  final PostEntity post;
  const EditPostSuccess(this.post);

  @override
  List<Object?> get props => [post];
}

/// Terminal state after the post was deleted from the edit screen.
class EditPostDeleted extends EditPostState {
  const EditPostDeleted();
}

class EditPostError extends EditPostState {
  final PostErrorCode code;
  const EditPostError(this.code);

  @override
  List<Object?> get props => [code];
}

// ── Bloc ──────────────────────────────────────────────────────────────────────

@injectable
class EditPostBloc extends Bloc<EditPostEvent, EditPostState> {
  final UpdatePostUseCase updatePost;
  final DeletePostUseCase deletePost;

  EditPostBloc({required this.updatePost, required this.deletePost})
      : super(const EditPostInitial()) {
    on<SubmitPostEdit>(_onSubmit);
    on<SubmitPostDelete>(_onDelete);
  }

  Future<void> _onDelete(
    SubmitPostDelete event,
    Emitter<EditPostState> emit,
  ) async {
    emit(const EditPostSubmitting());
    final result = await deletePost(DeletePostParams(postId: event.postId));
    result.fold(
      (failure) => emit(EditPostError(PostErrorMapper.getCode(failure))),
      (_) => emit(const EditPostDeleted()),
    );
  }

  Future<void> _onSubmit(
    SubmitPostEdit event,
    Emitter<EditPostState> emit,
  ) async {
    emit(const EditPostSubmitting());

    final result = await updatePost(
      UpdatePostUseCaseParams(
        postId: event.postId,
        params: UpdatePostParams(
          description: event.description ?? '',
          taggedPeople: event.taggedPeople,
          taggedCars: event.taggedCars,
          likesCountEnabled: event.likesCountEnabled,
          commentsCountEnabled: event.commentsCountEnabled,
          sharesCountEnabled: event.sharesCountEnabled,
          savedCountEnabled: event.savedCountEnabled,
        ),
      ),
    );

    result.fold(
      (failure) => emit(EditPostError(PostErrorMapper.getCode(failure))),
      (post) => emit(EditPostSuccess(post)),
    );
  }
}
