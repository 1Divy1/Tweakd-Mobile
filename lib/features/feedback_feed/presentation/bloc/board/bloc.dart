import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/feedback_message.dart';
import '../../../domain/entities/feedback_sort.dart';
import '../../../domain/usecases/get_feedback_board.dart';
import '../../../domain/usecases/manage_feedback_message.dart';
import '../../../domain/usecases/vote_feedback_message.dart';
import '../../utils/feedback_feed_error_mapper.dart';
import 'event.dart';
import 'state.dart';

/// Drives the main feedback board: sorting, cursor paging, optimistic voting
/// and the author's delete.
@injectable
class FeedbackBoardBloc extends Bloc<FeedbackBoardEvent, FeedbackBoardState> {
  final GetFeedbackBoardUseCase getBoard;
  final VoteFeedbackMessageUseCase voteMessage;
  final WithdrawFeedbackVoteUseCase withdrawVote;
  final DeleteFeedbackMessageUseCase deleteMessage;

  FeedbackBoardBloc({
    required this.getBoard,
    required this.voteMessage,
    required this.withdrawVote,
    required this.deleteMessage,
  }) : super(const FeedbackBoardState()) {
    on<LoadFeedbackBoard>(_onLoad);
    on<ChangeFeedbackSort>(_onChangeSort);
    on<RefreshFeedbackBoard>(_onRefresh);
    on<LoadMoreFeedbackBoard>(_onLoadMore);
    on<VoteOnFeedbackMessage>(_onVote);
    on<DeleteFeedbackMessage>(_onDelete);
  }

  Future<void> _onLoad(
    LoadFeedbackBoard event,
    Emitter<FeedbackBoardState> emit,
  ) {
    return _loadFirstPage(emit, sort: state.sort);
  }

  Future<void> _onChangeSort(
    ChangeFeedbackSort event,
    Emitter<FeedbackBoardState> emit,
  ) {
    if (event.sort == state.sort) return Future.value();
    // The cursor belongs to the previous ordering, so the list restarts.
    return _loadFirstPage(emit, sort: event.sort);
  }

  Future<void> _loadFirstPage(
    Emitter<FeedbackBoardState> emit, {
    required FeedbackSort sort,
  }) async {
    emit(state.copyWith(
      isLoading: true,
      sort: sort,
      messages: const [],
      clearNextCursor: true,
      clearError: true,
    ));

    final result = await getBoard(GetFeedbackBoardParams(sort: sort));

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorCode: FeedbackFeedErrorMapper.getCode(failure),
      )),
      (page) => emit(state.copyWith(
        isLoading: false,
        messages: page.items,
        nextCursor: page.nextCursor,
        clearNextCursor: page.nextCursor == null,
        clearError: true,
      )),
    );
  }

  Future<void> _onRefresh(
    RefreshFeedbackBoard event,
    Emitter<FeedbackBoardState> emit,
  ) async {
    try {
      final result = await getBoard(GetFeedbackBoardParams(sort: state.sort));

      result.fold(
        (failure) {
          // A failed refresh shouldn't blow away what's already on screen —
          // only an empty list has nothing to lose.
          if (state.messages.isEmpty) {
            emit(state.copyWith(
              isLoading: false,
              errorCode: FeedbackFeedErrorMapper.getCode(failure),
            ));
          }
        },
        (page) => emit(state.copyWith(
          isLoading: false,
          messages: page.items,
          nextCursor: page.nextCursor,
          clearNextCursor: page.nextCursor == null,
          clearError: true,
        )),
      );
    } finally {
      // Always release the indicator, even when the data is identical and the
      // emit above is a no-op (Bloc dedups equal states).
      if (!(event.completer?.isCompleted ?? true)) event.completer!.complete();
    }
  }

  Future<void> _onLoadMore(
    LoadMoreFeedbackBoard event,
    Emitter<FeedbackBoardState> emit,
  ) async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    emit(state.copyWith(isLoadingMore: true));

    final result = await getBoard(
      GetFeedbackBoardParams(sort: state.sort, cursor: state.nextCursor),
    );

    result.fold(
      // A failed "load more" keeps the current list; the user can scroll again.
      (_) => emit(state.copyWith(isLoadingMore: false)),
      (page) => emit(state.copyWith(
        isLoadingMore: false,
        // Vote counts shift under the "popular" sort while paging, so a page
        // can repeat a card we already hold — drop duplicates to keep keys
        // unique.
        messages: _dedup([...state.messages, ...page.items]),
        nextCursor: page.nextCursor,
        clearNextCursor: page.nextCursor == null,
      )),
    );
  }

  /// Applies the vote optimistically, then replaces the card with the server's
  /// version (which carries the authoritative tallies) or rolls it back.
  Future<void> _onVote(
    VoteOnFeedbackMessage event,
    Emitter<FeedbackBoardState> emit,
  ) async {
    final index = state.messages.indexWhere((m) => m.id == event.messageId);
    if (index == -1) return;

    final original = state.messages[index];
    // Tapping the arrow that's already active withdraws the vote.
    final isWithdrawal = original.myVote == event.value;
    final nextVote = isWithdrawal ? null : event.value;

    emit(state.copyWith(
      messages: _replaceAt(state.messages, index, original.withVote(nextVote)),
    ));

    final result = isWithdrawal
        ? await withdrawVote(WithdrawFeedbackVoteParams(event.messageId))
        : await voteMessage(VoteFeedbackMessageParams(
            messageId: event.messageId,
            value: event.value,
          ));

    result.fold(
      (failure) => _replaceMessage(
        emit,
        event.messageId,
        original,
        actionError: FeedbackFeedErrorMapper.getCode(failure),
      ),
      (updated) => _replaceMessage(emit, event.messageId, updated),
    );
  }

  Future<void> _onDelete(
    DeleteFeedbackMessage event,
    Emitter<FeedbackBoardState> emit,
  ) async {
    final index = state.messages.indexWhere((m) => m.id == event.messageId);
    if (index == -1) return;

    final removed = state.messages[index];

    // Drop the card straight away — deletes are hard, so there's nothing to
    // come back for unless the request fails.
    emit(state.copyWith(
      messages: [...state.messages]..removeAt(index),
    ));

    final result = await deleteMessage(FeedbackMessageIdParams(event.messageId));

    result.fold(
      (failure) {
        final code = FeedbackFeedErrorMapper.getCode(failure);
        // 404 means it's already gone, so leaving it removed is correct.
        // Anything else (notably the 409 "staff picked it up" case) puts the
        // card back where it was, now visibly out of the author's hands once
        // the next refresh lands.
        if (code == FeedbackFeedErrorCode.notFound) {
          emit(state.copyWith(actionError: code));
          return;
        }
        final restored = [...state.messages];
        restored.insert(index.clamp(0, restored.length), removed);
        emit(state.copyWith(messages: restored, actionError: code));
      },
      (_) {},
    );
  }

  /// Swaps a single card by id, re-finding it in the *latest* state (an
  /// in-flight request may have been overtaken by a refresh).
  void _replaceMessage(
    Emitter<FeedbackBoardState> emit,
    String messageId,
    FeedbackMessageEntity message, {
    FeedbackFeedErrorCode? actionError,
  }) {
    final index = state.messages.indexWhere((m) => m.id == messageId);
    if (index == -1) {
      if (actionError != null) emit(state.copyWith(actionError: actionError));
      return;
    }
    emit(state.copyWith(
      messages: _replaceAt(state.messages, index, message),
      actionError: actionError,
    ));
  }

  List<FeedbackMessageEntity> _replaceAt(
    List<FeedbackMessageEntity> messages,
    int index,
    FeedbackMessageEntity message,
  ) {
    final next = [...messages];
    next[index] = message;
    return next;
  }

  List<FeedbackMessageEntity> _dedup(List<FeedbackMessageEntity> messages) {
    final seen = <String>{};
    return [
      for (final m in messages)
        if (seen.add(m.id)) m,
    ];
  }
}
