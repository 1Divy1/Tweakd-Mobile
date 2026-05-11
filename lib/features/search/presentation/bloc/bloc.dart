import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/base_failures.dart';
import '../../domain/usecases/search_users.dart';
import '../utils/search_error_mapper.dart';
import 'event.dart';
import 'state.dart';

const _debounceDuration = Duration(milliseconds: 300);
const _minQueryLength = 2;

@injectable
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchUsersUseCase searchUsers;

  Timer? _debounceTimer;
  CancelToken? _activeToken;

  SearchBloc({required this.searchUsers}) : super(const SearchInitial()) {
    on<SearchQueryChanged>(_onQueryChanged);
    on<SearchCleared>(_onCleared);
    on<PerformSearch>(_onPerformSearch);
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    _cancelActive();
    return super.close();
  }

  void _onQueryChanged(SearchQueryChanged event, Emitter<SearchState> emit) {
    _debounceTimer?.cancel();
    _cancelActive();

    final query = event.query.trim();

    if (query.length < _minQueryLength) {
      emit(const SearchInitial());
      return;
    }

    _debounceTimer = Timer(_debounceDuration, () {
      if (isClosed) return;
      add(PerformSearch(query));
    });
  }

  void _onCleared(SearchCleared event, Emitter<SearchState> emit) {
    _debounceTimer?.cancel();
    _cancelActive();
    emit(const SearchInitial());
  }

  Future<void> _onPerformSearch(
    PerformSearch event,
    Emitter<SearchState> emit,
  ) async {
    final token = CancelToken();
    _activeToken = token;

    emit(SearchLoading(event.query));

    final result = await searchUsers(
      SearchUsersParams(query: event.query, cancelToken: token),
    );

    if (token.isCancelled) return;

    result.fold(
      (failure) {
        if (failure is RequestCancelledFailure) return;
        emit(
          SearchError(
            query: event.query,
            message: SearchErrorMapper.getMessage(failure),
          ),
        );
      },
      (results) =>
          emit(SearchSuccess(query: event.query, results: results)),
    );
  }

  void _cancelActive() {
    final token = _activeToken;
    if (token != null && !token.isCancelled) {
      token.cancel();
    }
    _activeToken = null;
  }
}
