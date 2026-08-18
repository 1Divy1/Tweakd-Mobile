import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/feedback_message.dart';
import '../../../domain/usecases/get_feedback_board.dart';
import '../../utils/feedback_feed_error_mapper.dart';
import 'event.dart';
import 'state.dart';

/// Drives the read-only "Completed requests" screen: load, refresh and page.
@injectable
class CompletedFeedbackBloc
    extends Bloc<CompletedFeedbackEvent, CompletedFeedbackState> {
  final GetCompletedFeedbackUseCase getCompleted;

  CompletedFeedbackBloc({required this.getCompleted})
      : super(const CompletedFeedbackState()) {
    on<LoadCompletedFeedback>(_onLoad);
    on<RefreshCompletedFeedback>(_onRefresh);
    on<LoadMoreCompletedFeedback>(_onLoadMore);
  }

  Future<void> _onLoad(
    LoadCompletedFeedback event,
    Emitter<CompletedFeedbackState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await getCompleted(const GetCompletedFeedbackParams());

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
    RefreshCompletedFeedback event,
    Emitter<CompletedFeedbackState> emit,
  ) async {
    try {
      final result = await getCompleted(const GetCompletedFeedbackParams());

      result.fold(
        (failure) {
          // Keep whatever is already on screen on a failed refresh.
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
      if (!(event.completer?.isCompleted ?? true)) event.completer!.complete();
    }
  }

  Future<void> _onLoadMore(
    LoadMoreCompletedFeedback event,
    Emitter<CompletedFeedbackState> emit,
  ) async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    emit(state.copyWith(isLoadingMore: true));

    final result = await getCompleted(
      GetCompletedFeedbackParams(cursor: state.nextCursor),
    );

    result.fold(
      (_) => emit(state.copyWith(isLoadingMore: false)),
      (page) => emit(state.copyWith(
        isLoadingMore: false,
        messages: _dedup([...state.messages, ...page.items]),
        nextCursor: page.nextCursor,
        clearNextCursor: page.nextCursor == null,
      )),
    );
  }

  List<FeedbackMessageEntity> _dedup(List<FeedbackMessageEntity> messages) {
    final seen = <String>{};
    return [
      for (final m in messages)
        if (seen.add(m.id)) m,
    ];
  }
}
