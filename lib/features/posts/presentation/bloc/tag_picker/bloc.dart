import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:car_social_media_app/features/garage/domain/usecases/get_garage_by_username.dart';
import 'package:car_social_media_app/features/search/domain/usecases/search_users.dart';
import 'event.dart';
import 'state.dart';

const _debounceDuration = Duration(milliseconds: 300);
const _minQueryLength = 2;

/// Powers the create-post tags step. Reuses the existing profile-search and
/// garage-by-username use cases: people search drives the typeahead, and a
/// tagged person's garage drives the car-picker sheet. The owner-must-be-tagged
/// constraint is honoured by construction — cars are only reachable through an
/// already-tagged person.
@injectable
class TagPickerBloc extends Bloc<TagPickerEvent, TagPickerState> {
  final SearchUsersUseCase searchUsers;
  final GetGarageByUsernameUseCase getGarageByUsername;

  Timer? _debounceTimer;
  CancelToken? _activeToken;

  TagPickerBloc({
    required this.searchUsers,
    required this.getGarageByUsername,
  }) : super(const TagPickerState()) {
    on<PeopleQueryChanged>(_onQueryChanged);
    on<PeopleSearchRequested>(_onSearchRequested);
    on<PeopleResultsCleared>(_onResultsCleared);
    on<OwnerCarsRequested>(_onOwnerCarsRequested);
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    _cancelActive();
    return super.close();
  }

  void _onQueryChanged(PeopleQueryChanged event, Emitter<TagPickerState> emit) {
    _debounceTimer?.cancel();
    _cancelActive();

    final query = event.query.trim();
    if (query.length < _minQueryLength) {
      emit(state.copyWith(
        peopleStatus: TagLoadStatus.idle,
        peopleResults: const [],
      ));
      return;
    }

    _debounceTimer = Timer(_debounceDuration, () {
      if (isClosed) return;
      add(PeopleSearchRequested(query));
    });
  }

  Future<void> _onSearchRequested(
    PeopleSearchRequested event,
    Emitter<TagPickerState> emit,
  ) async {
    final token = CancelToken();
    _activeToken = token;

    emit(state.copyWith(peopleStatus: TagLoadStatus.loading));

    final result = await searchUsers(
      SearchUsersParams(query: event.query, cancelToken: token),
    );

    if (token.isCancelled) return;

    result.fold(
      (_) => emit(state.copyWith(
        peopleStatus: TagLoadStatus.failure,
        peopleResults: const [],
      )),
      (results) => emit(state.copyWith(
        peopleStatus: TagLoadStatus.success,
        peopleResults: results,
      )),
    );
  }

  void _onResultsCleared(
    PeopleResultsCleared event,
    Emitter<TagPickerState> emit,
  ) {
    _debounceTimer?.cancel();
    _cancelActive();
    emit(state.copyWith(
      peopleStatus: TagLoadStatus.idle,
      peopleResults: const [],
    ));
  }

  Future<void> _onOwnerCarsRequested(
    OwnerCarsRequested event,
    Emitter<TagPickerState> emit,
  ) async {
    emit(state.copyWith(
      carsStatus: TagLoadStatus.loading,
      ownerUsername: event.username,
      ownerCars: const [],
    ));

    final result = await getGarageByUsername(
      GetGarageByUsernameParams(username: event.username),
    );

    result.fold(
      (_) => emit(state.copyWith(carsStatus: TagLoadStatus.failure)),
      (garage) => emit(state.copyWith(
        carsStatus: TagLoadStatus.success,
        ownerCars: garage.cars,
      )),
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
