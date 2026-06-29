import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/error/base_failures.dart';
import '../../../domain/usecases/check_username_availability.dart';
import '../../utils/username_validator.dart';
import 'event.dart';
import 'state.dart';

/// Wait for typing to settle before hitting the backend. Mirrors the search
/// page's debounce: each keystroke resets the timer, so only the last handle in
/// a burst of typing is actually checked.
const _debounceDuration = Duration(milliseconds: 400);

@injectable
class UsernameAvailabilityBloc
    extends Bloc<UsernameAvailabilityEvent, UsernameAvailabilityState> {
  final CheckUsernameAvailabilityUseCase checkUsername;

  Timer? _debounceTimer;
  CancelToken? _activeToken;

  UsernameAvailabilityBloc({required this.checkUsername})
      : super(const UsernameAvailabilityInitial()) {
    on<UsernameChanged>(_onChanged);
    on<PerformUsernameCheck>(_onPerformCheck);
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    _cancelActive();
    return super.close();
  }

  void _onChanged(
    UsernameChanged event,
    Emitter<UsernameAvailabilityState> emit,
  ) {
    // A newer keystroke arrived: drop the pending timer and any in-flight check
    // so we never race an outdated request.
    _debounceTimer?.cancel();
    _cancelActive();

    final username = event.username.trim();

    if (username.isEmpty) {
      emit(const UsernameAvailabilityInitial());
      return;
    }

    // Format is validated instantly and locally — no point asking the backend
    // about a handle that can't be valid.
    final formatError = validateOnboardingUsername(username);
    if (formatError != null) {
      emit(UsernameAvailabilityInvalid(formatError));
      return;
    }
    // formatError carries a UsernameValidationError code; the UI localizes it.

    // Well-formed: show the checking hint immediately, but only fire the
    // request once typing pauses for [_debounceDuration].
    emit(UsernameAvailabilityChecking(username));
    _debounceTimer = Timer(_debounceDuration, () {
      if (isClosed) return;
      add(PerformUsernameCheck(username));
    });
  }

  Future<void> _onPerformCheck(
    PerformUsernameCheck event,
    Emitter<UsernameAvailabilityState> emit,
  ) async {
    final token = CancelToken();
    _activeToken = token;

    final result = await checkUsername(
      CheckUsernameAvailabilityParams(
        username: event.username,
        cancelToken: token,
      ),
    );

    if (token.isCancelled) return;

    result.fold(
      (failure) {
        if (failure is RequestCancelledFailure) return;
        emit(UsernameAvailabilityFailed(username: event.username));
      },
      (isAvailable) => emit(
        isAvailable
            ? UsernameAvailable(event.username)
            : UsernameTaken(event.username),
      ),
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
