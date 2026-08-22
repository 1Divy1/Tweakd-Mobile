import 'dart:async';

import 'package:tweakd/features/authentication/domain/usecases/auth/check_auth_status.dart';
import 'package:tweakd/features/authentication/presentation/bloc/event.dart';
import 'package:tweakd/features/authentication/presentation/bloc/state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/auth/log_out.dart';
import '../../domain/usecases/auth/watch_external_sign_in.dart';
import '../../domain/usecases/login/email_password_signin.dart';
import '../../domain/usecases/login/google_signin.dart';
import '../utils/auth_error_mapper.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final CheckAuthStatusUseCase checkAuthStatus;
  final EmailPasswordSignIn loginUser;
  final GoogleSignIn googleSignIn;
  final LogOut logOut;
  final WatchExternalSignIn watchExternalSignIn;

  StreamSubscription<void>? _externalSignInSubscription;

  AuthBloc({
    required this.checkAuthStatus,
    required this.loginUser,
    required this.googleSignIn,
    required this.logOut,
    required this.watchExternalSignIn,
  }) : super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<EmailPasswordLoginSubmitted>(_onLoginSubmitted);
    on<GoogleLoginRequested>(_onGoogleLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);

    // The sign-up confirmation link reopens the app and Supabase establishes
    // the session on its own — no page asked for it, so nothing would react
    // without this. Ignored while one of this bloc's own flows is running or
    // once a user is already resolved, so a normal sign-in doesn't trigger a
    // second profile fetch and a duplicate redirect.
    _externalSignInSubscription = watchExternalSignIn().listen((_) {
      if (state is AuthLoading ||
          state is Authenticated ||
          state is AuthenticatedRequiresOnboarding) {
        return;
      }
      add(CheckAuthStatus());
    });
  }

  @override
  Future<void> close() async {
    await _externalSignInSubscription?.cancel();
    return super.close();
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {

    final result = await checkAuthStatus(NoParams());

    result.fold(
      (failure) {
        emit(AuthInitial());
      },
      (user) {
        if (user.requiresOnboarding) {
          emit(AuthenticatedRequiresOnboarding(user));
        } else {
          emit(Authenticated(user));
        }
      },
    );
  }

  Future<void> _onLoginSubmitted(
    EmailPasswordLoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final params = LoginParams(email: event.email, password: event.password);

    final result = await loginUser(params);

    result.fold(
      (failure) => emit(AuthError(AuthErrorMapper.getCode(failure))),
      (user) {
        // Email/password accounts are created with `requires_onboarding = true`
        // (set by the `on_auth_user_created` trigger), so this branch is the
        // normal path for a freshly confirmed signup — not an edge case.
        if (user.requiresOnboarding) {
          emit(AuthenticatedRequiresOnboarding(user));
        } else {
          emit(Authenticated(user));
        }
      },
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await logOut(NoParams());

    result.fold(
      (failure) => emit(AuthError(AuthErrorMapper.getCode(failure))),
      (_) => emit(Unauthenticated()),
    );
  }

  FutureOr<void> _onGoogleLoginRequested(
    GoogleLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    debugPrint("Event received: GoogleLoginRequested");

    final result = await googleSignIn(NoParams());
    debugPrint("googleSignIn usecase result: $result");

    result.fold(
      (failure) => emit(AuthError(AuthErrorMapper.getCode(failure))),
      (user) {
        if (user.requiresOnboarding) {
          emit(AuthenticatedRequiresOnboarding(user));
        } else {
          emit(Authenticated(user));
        }
      },
    );
  }
}
