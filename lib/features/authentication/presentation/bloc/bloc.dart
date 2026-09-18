import 'dart:async';

import 'package:tweakd/features/authentication/domain/usecases/auth/check_auth_status.dart';
import 'package:tweakd/features/authentication/presentation/bloc/event.dart';
import 'package:tweakd/features/authentication/presentation/bloc/state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/analytics/analytics_events.dart';
import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/social_auth_intent.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/auth/log_out.dart';
import '../../domain/usecases/auth/watch_external_sign_in.dart';
import '../../domain/usecases/login/email_password_signin.dart';
import '../../domain/usecases/login/apple_signin.dart';
import '../../domain/usecases/login/complete_social_sign_in.dart';
import '../../domain/usecases/login/google_signin.dart';
import '../utils/auth_error_mapper.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final CheckAuthStatusUseCase checkAuthStatus;
  final EmailPasswordSignIn loginUser;
  final GoogleSignIn googleSignIn;
  final AppleSignIn appleSignIn;
  final CompleteSocialSignIn completeSocialSignIn;
  final LogOut logOut;
  final WatchExternalSignIn watchExternalSignIn;
  final AnalyticsService analytics;

  StreamSubscription<void>? _externalSignInSubscription;

  /// Set while an Android Apple sign-in is out in the browser, so the session
  /// it brings back is checked against the page it was started from. Only
  /// held in memory: if Android kills the app while the browser is open, the
  /// redirect cold-starts it and the session is resolved without the check.
  SocialAuthIntent? _pendingAppleIntent;

  AuthBloc({
    required this.checkAuthStatus,
    required this.loginUser,
    required this.googleSignIn,
    required this.appleSignIn,
    required this.completeSocialSignIn,
    required this.logOut,
    required this.watchExternalSignIn,
    this.analytics = const NoopAnalyticsService(),
  }) : super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<EmailPasswordLoginSubmitted>(_onLoginSubmitted);
    on<GoogleLoginRequested>(_onGoogleLoginRequested);
    on<AppleLoginRequested>(_onAppleLoginRequested);
    on<AppleRedirectSignedIn>(_onAppleRedirectSignedIn);
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
      final appleIntent = _pendingAppleIntent;
      _pendingAppleIntent = null;
      add(
        appleIntent != null
            ? AppleRedirectSignedIn(appleIntent)
            : CheckAuthStatus(),
      );
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
        analytics.track(AnalyticsEvents.signedIn, {'method': 'email'});
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

    // Sent before signing out: once the session is gone, tracking is off.
    analytics.track(AnalyticsEvents.signedOut);

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
    _pendingAppleIntent = null;
    debugPrint("Event received: GoogleLoginRequested");

    final result = await googleSignIn(event.intent);
    debugPrint("googleSignIn usecase result: $result");

    result.fold(
      (failure) => emit(AuthError(AuthErrorMapper.getCode(failure))),
      (user) {
        _trackSocial(event.intent, 'google', user);
        if (user.requiresOnboarding) {
          emit(AuthenticatedRequiresOnboarding(user));
        } else {
          emit(Authenticated(user));
        }
      },
    );
  }

  FutureOr<void> _onAppleLoginRequested(
    AppleLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    _pendingAppleIntent = null;
    debugPrint("Event received: AppleLoginRequested");

    final result = await appleSignIn(event.intent);

    result.fold(
      (failure) => emit(AuthError(AuthErrorMapper.getCode(failure))),
      (outcome) {
        // Android: the browser is open and this bloc's part is done. The session
        // arrives later through the deep link, which the external sign-in
        // listener in the constructor turns into an AppleRedirectSignedIn, so
        // the page the button was on still decides what the account may do.
        //
        // Dropping back to Unauthenticated is load-bearing, not cosmetic: that
        // listener ignores events while the state is AuthLoading, so staying in
        // it would strand the user on a spinner even after a *successful*
        // sign-in. It also means abandoning the browser needs no recovery path —
        // a browser has no "user gave up" callback, and this way the login page
        // is simply left exactly as the user left it.
        if (outcome.awaitingRedirect) {
          _pendingAppleIntent = event.intent;
          emit(Unauthenticated());
          return;
        }

        // iOS: resolved in-process, so a user is always present here.
        final user = outcome.user;
        if (user == null) {
          emit(const AuthError(AuthErrorCode.generic));
          return;
        }
        _trackSocial(event.intent, 'apple', user);
        if (user.requiresOnboarding) {
          emit(AuthenticatedRequiresOnboarding(user));
        } else {
          emit(Authenticated(user));
        }
      },
    );
  }

  Future<void> _onAppleRedirectSignedIn(
    AppleRedirectSignedIn event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await completeSocialSignIn(event.intent);

    result.fold(
      (failure) => emit(AuthError(AuthErrorMapper.getCode(failure))),
      (user) {
        _trackSocial(event.intent, 'apple', user);
        if (user.requiresOnboarding) {
          emit(AuthenticatedRequiresOnboarding(user));
        } else {
          emit(Authenticated(user));
        }
      },
    );
  }

  /// `signed_up` for a new account made from the sign-up page, `signed_in`
  /// otherwise. Tapping Google on the sign-up page with an account that
  /// already exists just signs in, so "new" is read off onboarding: every
  /// account starts with it pending.
  void _trackSocial(SocialAuthIntent intent, String method, UserEntity user) {
    final isNewAccount = intent is SignUpIntent && user.requiresOnboarding;
    analytics.track(
      isNewAccount ? AnalyticsEvents.signedUp : AnalyticsEvents.signedIn,
      {'method': method},
    );
  }
}
