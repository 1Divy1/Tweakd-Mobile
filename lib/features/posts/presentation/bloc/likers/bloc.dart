import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/post_user.dart';
import '../../../domain/usecases/get_post_likers.dart';

// ── Events ────────────────────────────────────────────────────────────────────

sealed class LikersEvent extends Equatable {
  const LikersEvent();

  @override
  List<Object?> get props => [];
}

class LoadLikers extends LikersEvent {
  final String postId;
  const LoadLikers(this.postId);

  @override
  List<Object?> get props => [postId];
}

class LoadMoreLikers extends LikersEvent {
  const LoadMoreLikers();
}

// ── State ─────────────────────────────────────────────────────────────────────

enum LikersStatus { loading, success, failure }

class LikersState extends Equatable {
  final LikersStatus status;
  final List<PostUserEntity> likers;
  final String? nextCursor;
  final bool isLoadingMore;

  const LikersState({
    this.status = LikersStatus.loading,
    this.likers = const [],
    this.nextCursor,
    this.isLoadingMore = false,
  });

  bool get hasMore => nextCursor != null;

  LikersState copyWith({
    LikersStatus? status,
    List<PostUserEntity>? likers,
    String? nextCursor,
    bool? isLoadingMore,
  }) {
    return LikersState(
      status: status ?? this.status,
      likers: likers ?? this.likers,
      nextCursor: nextCursor ?? this.nextCursor,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [status, likers, nextCursor, isLoadingMore];
}

// ── Bloc ──────────────────────────────────────────────────────────────────────

/// Backs the likers bottom sheet: a cursor-paged list of the users who liked a
/// post, most recent first.
@injectable
class LikersBloc extends Bloc<LikersEvent, LikersState> {
  final GetPostLikersUseCase getLikers;

  late String _postId;

  LikersBloc({required this.getLikers}) : super(const LikersState()) {
    on<LoadLikers>(_onLoad);
    on<LoadMoreLikers>(_onLoadMore);
  }

  Future<void> _onLoad(LoadLikers event, Emitter<LikersState> emit) async {
    _postId = event.postId;
    emit(const LikersState(status: LikersStatus.loading));
    final result = await getLikers(GetPostLikersParams(postId: _postId));
    result.fold(
      (_) => emit(const LikersState(status: LikersStatus.failure)),
      (page) => emit(LikersState(
        status: LikersStatus.success,
        likers: page.items,
        nextCursor: page.nextCursor,
      )),
    );
  }

  Future<void> _onLoadMore(
    LoadMoreLikers event,
    Emitter<LikersState> emit,
  ) async {
    if (state.isLoadingMore || !state.hasMore) return;
    emit(state.copyWith(isLoadingMore: true));

    final result = await getLikers(
      GetPostLikersParams(postId: _postId, cursor: state.nextCursor),
    );
    result.fold(
      (_) => emit(state.copyWith(isLoadingMore: false)),
      (page) => emit(LikersState(
        status: LikersStatus.success,
        likers: [...state.likers, ...page.items],
        nextCursor: page.nextCursor,
      )),
    );
  }
}
